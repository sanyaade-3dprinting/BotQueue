<?
	class User extends Model
	{		
		public static $me = null;
		
		public function __construct($id = null)
		{
			parent::__construct($id, "users");
		}
		
		public function getFullName() {
			return $this->get('first_name') . " " . $this->get('last_name');
		}
		
		public static function authenticate()
		{
			//are we already authenticated?
			if ($_SESSION['userid'])
			{
				//attempt to load our user.
				self::$me = new User($_SESSION['userid']);

				//if it fails, nuke it.
				if (!self::$me->isHydrated()) {
					self::$me = null;
					unset($_SESSION['userid']);
				} else {
				  // uncomment this section to temporarily lock down the site and prevent logins
          // if (!self::$me->isAdmin()) {
          //    self::$me = null;
          //    unset($_SESSION['userid']);
          //  }
				}
			}
			//okay, how about our cookie?
			else if ($_COOKIE['token'])
				self::loginWithToken($_COOKIE['token']);

			//if that user wasnt found, bail!
			if (self::$me instanceOf User && !self::$me->isHydrated())
				self::$me = null;
			
			if (User::isLoggedIn())
				self::$me->setActive();
		}
		
		public static function loginWithToken($token, $createSession = true)
		{
			$data = unserialize(base64_decode($token));

			if (is_array($data) && $data['id'] && $data['token'])
			{
				$user = new User($data['id']);
				
				if ($user->isHydrated())
				{
					if ($user->checkToken($data['token']))
					{
						self::createLogin($user, $createSession);
					}
				}
			}
		}
		
		public static function login($username, $password)
		{
			//find the user/pass combo.
			$user = User::byUsernameAndPassword($username, $password);
			if ($user->isHydrated())
				self::createLogin($user);
		}
		
		public static function createLogin($user, $createSession = true)
		{
			self::$me = $user;

			if ($createSession == true)
				$_SESSION['userid'] = $user->id;
		}
		
		public function canEdit()
		{
			return ($this->isMe() || User::isAdmin());
		}
		
		public static function isAdmin($type='') {
		  if ($type == '') {
		    $type = 'is_admin';
	    } else {
	      $type = "is_{$type}_admin";
		  }
		  
			if (self::isLoggedIn() && (self::$me->get("is_admin") || self::$me->get($type))) {
				return true;
			} else {
  			return false;
			}
		}
		
		public function isBeta()
		{
			return User::$me->isAdmin();
		}
		
		public static function isLoggedIn()
		{
			return (self::$me instanceOf User && self::$me->isHydrated());
		}
		
		public function checkToken($t)
		{
			$token = Token::byToken($t);
			if ($token->isHydrated() && $token->get('user_id') == $this->id)
				return true;
			else
				return false;
		}
		
		public function createToken()
		{
			$hash = sha1(microtime() . mt_rand() . "salty bastard");

			$token = new Token();
			$token->set('user_id', $this->id);
			$token->set('hash', $hash);
			$token->set('expire_date', date("Y-m-d H:i:s", strtotime("+1 year")));
			$token->save();
			
			return $token;
		}
		
		public static function hashPass($pass)
		{
			return sha1($pass);
		}
		
		public static function byUsername($username)
		{
			//look up the token
			$sql = "
				SELECT id
				FROM users
				WHERE username = '$username'
			";
			$id = db()->getValue($sql);
			
			//send it!
			return new User($id);
		}

		public static function byUsernameAndPassword($username, $password)
		{
			$pass_hash = sha1($password);

			//look up the combo.
			$sql = "
				SELECT id
				FROM users
				WHERE username = '$username'
					AND pass_hash = '$pass_hash'
			";
			$id = db()->getValue($sql);
			
			//send it!
			return new User($id);
		}
		
		public static function byEmail($email)
		{
			//look up the token
			$sql = "
				SELECT id
				FROM users
				WHERE email = '$email'
			";
			$id = db()->getValue($sql);
			
			//send it!
			return new User($id);
		}
		
		public function getUrl()
		{
			return "/" . $this->get('username');
		}
		
		public function getiPhoneUrl()
		{
			return '/iphone/user:' . $this->id;
		}
		
		public function getName($short = false)
		{
			return $this->get('username');
		}
		
		public function setActive()
		{
			if (User::isLoggedIn())
			{
				$last_seen = strtotime($this->get('last_active'));

				if (time() - $last_seen > 300)
				{
					$this->set('last_active', date("Y-m-d H:i:s"));
					$this->save();
				}
			}
		}
		
		public function isMe()
		{
			if (User::isLoggedIn() && User::$me->id == $this->id)
				return true;
			
			return false;
		}
		
		public function delete()
		{
			//okay, nuke us now.
			parent::delete();
		}
		
		public function getActivityStream()
		{
			$sql = "
				SELECT id, user_id
				FROM activities
				WHERE user_id = '{$this->id}'
				ORDER BY id DESC
			";
			
			return new Collection($sql, array(
				'User' => 'user_id',
				'Activity' => 'id'
			));
		}
		
		public function getAllUsers() {
			$sql = "
				SELECT id, username, first_name, last_name, email
				FROM users
				ORDER BY last_name ASC
			";
			$col = new Collection($sql, array("User" => "id"));
			
			return $col->getMap();
		}
	}
?>