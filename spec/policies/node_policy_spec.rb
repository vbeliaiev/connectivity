require 'rails_helper'

describe NodePolicy do
  let!(:user) { create(:user) }

  subject { described_class }

  permissions :update?, :destroy? do
    context 'when the user is owner of the article' do
      let!(:article) { create(:article, author: user) }

      it 'grantes permissions' do
        expect(subject).to permit(user, article)
      end
    end

    context 'when the user is not owner of the article' do
      let!(:organisation) { create(:organisation) }
      let!(:article) { create(:article, organisation: organisation) }

      it 'restricts when the user is not a part of organisation' do
        expect(subject).not_to permit(user, article)
      end

      it 'restricts when the user is a member in the organisation' do
        OrganisationsUser.create(user: user, organisation: organisation, role: :member)
        expect(subject).not_to permit(user, article)
      end

      %w[moderator admin owner].each do |role|
        it "permits when the user is #{role} in the organisation" do
          OrganisationsUser.create(user: user, organisation: organisation, role: role)
          expect(subject).to permit(user, article)
        end
      end
    end
  end

  permissions :create? do
    let(:organisation) { create(:organisation) }
    let(:article) { build(:article, author: user)}
    before { user.update(current_organisation: organisation) }


    it 'allows to create an article only when user is in the organisation' do
      OrganisationsUser.create(user: user, organisation: organisation, role: :member)
      expect(subject).to permit(user, article)
    end

    it 'restricts when the user is not a part of the organisation' do
      expect(subject).not_to permit(user, article)
    end
  end

  permissions :show? do
    let(:organisation) { create(:organisation) }
    let(:article) { create(:article, visibility_level: :internal, organisation: organisation) }

    context 'when the user is in the organisation' do
      before { OrganisationsUser.create(user: user, organisation: organisation, role: :member) }

      it 'allows to see all articles' do
        expect(subject).to permit(user, article)
      end
    end

    context 'when the user is not in the organisation' do
      it 'allows to see public articles' do
        article.update(visibility_level: :public_visibility)
        expect(subject).to permit(user, article)
      end

      it 'restricts private articles' do
        expect(subject).not_to permit(user, article)
      end
    end
  end

  permissions :index? do
    let(:user) { create(:user) }

    it 'allows all to get index page' do
      expect(subject).to permit(user, Article)
    end
  end

  describe ArticlePolicy::Scope do
    let(:resolved_scope) do
      described_class.new(user, Article.all).resolve
    end

    context 'when the user is not logged in' do
      let(:user) { nil }

      let(:public_article) { create(:article, visibility_level: :public_visibility) }
      let(:internal_article) { create(:article, visibility_level: :internal) }

      it 'returns only public articles' do
        expect(resolved_scope).to contain_exactly(public_article)
      end
    end

  end
end
