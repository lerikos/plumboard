class User < ActiveRecord::Base
  rolify

  # Include default devise modules. Others available are:
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
  	 :token_authenticatable, :confirmable,
  	 :lockable, :timeoutable and :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation, :remember_me, :birth_date, :gender,
  	:picture_attributes

  # define relationships
  has_many :contacts, :as => :contactable, :dependent => :destroy
  has_many :listings, foreign_key: :seller_id
  has_many :temp_listings, foreign_key: :seller_id, dependent: :destroy

  has_many :site_users, :dependent => :destroy
  has_many :sites, :through => :site_users

  has_many :user_interests, :dependent => :destroy
  has_many :interests, :through => :user_interests

  has_many :posts
  has_many :transactions, dependent: :destroy

  has_one :picture, :as => :imageable, :dependent => :destroy
  accepts_nested_attributes_for :picture, :allow_destroy => true

  # name format validators
  name_regex = 	/^[A-Z]'?['-., a-zA-Z]+$/i

  # validate added fields  				  
  validates :first_name,  :presence => true,
            :length   => { :maximum => 30 },
 	    :format => { :with => name_regex }  

  validates :last_name,  :presence => true,
            :length   => { :maximum => 30 },
 	    :format => { :with => name_regex }  

  validates :birth_date,  :presence => true  
  validates :gender,  :presence => true
  validates :password, presence: true
  validates :password_confirmation, presence: true

  def name
    [first_name, last_name].join " "
  end
end
