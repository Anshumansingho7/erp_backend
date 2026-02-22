require "test_helper"

class JwtDenylistTest < ActiveSupport::TestCase
  def test_jwt_denylist_has_jti
    jwt = jwt_denylists(:jwt_denylist_one)
    assert jwt.jti.present?
  end

  def test_jwt_denylist_has_exp
    jwt = jwt_denylists(:jwt_denylist_one)
    assert jwt.exp.present?
  end

  def test_jwt_denylist_create
    jwt = JwtDenylist.new(jti: "test-jti-123", exp: (Time.now + 3.hours).to_i)
    assert jwt.valid?
    assert jwt.save
  end

  def test_jwt_denylist_includes_jwt_authenticable
    jwt = jwt_denylists(:jwt_denylist_one)
    assert_instance_of JwtDenylist, jwt
  end

  def test_jwt_denylist_rev_jti
    jwt = jwt_denylists(:jwt_denylist_one)
    assert_equal jwt.jti, jwt_denylists(:jwt_denylist_one).jti
  end
end
