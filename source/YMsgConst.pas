{
  Original code: TYMsgCore - http://sourceforge.net/projects/tymsgcore
  Author: Hamid_PaK [PRAISER] - praiser_man@yahoo.com

  Contact: devi[dot]mandiri[at]gmail[dot]com
}

unit YMsgConst;

interface

const
  YAHOO_PROTOCOL_SIGN = 'YMSG';
  YAHOO_PROTO_VERSION = $10;

  YAHOO_SERVICE_LOGON = $01;
  YAHOO_SERVICE_LOGOFF = $02;
  YAHOO_SERVICE_ISAWAY = $03;
  YAHOO_SERVICE_ISBACK = $04;
  YAHOO_SERVICE_IDLE = $05;
  YAHOO_SERVICE_MESSAGE = $06;
  YAHOO_SERVICE_IDACT = $07;
  YAHOO_SERVICE_IDDEACT = $08;
  YAHOO_SERVICE_MAILSTAT = $09;
  YAHOO_SERVICE_SKINNAME = $15;
  YAHOO_SERVICE_USERSTAT = $0a;
  YAHOO_SERVICE_NEWMAIL = $0b;
  YAHOO_SERVICE_CHATINVITE = $0c;
  YAHOO_SERVICE_CALENDAR = $0d;
  YAHOO_SERVICE_NEWPERSONALMAIL = $0e;
  YAHOO_SERVICE_NEWCONTACT = $0f;
  YAHOO_SERVICE_ADDIDENT = $10;
  YAHOO_SERVICE_ADDIGNORE = $11;
  YAHOO_SERVICE_PING = $12;
  YAHOO_SERVICE_GROUPRENAME = $13;
  YAHOO_SERVICE_SYSMESSAGE = $14;
  YAHOO_SERVICE_PASSTHROUGH2 = $16;
  YAHOO_SERVICE_CONFINVITE = $18;
  YAHOO_SERVICE_CONFLOGON = $19;
  YAHOO_SERVICE_CONFDECLINE = $1a;
  YAHOO_SERVICE_CONFLOGOFF = $1b;
  YAHOO_SERVICE_CONFADDINVITE = $1c;
  YAHOO_SERVICE_CONFMSG = $1d;
  YAHOO_SERVICE_CHATLOGON = $1e;
  YAHOO_SERVICE_CHATLOGOFF = $1f;
  YAHOO_SERVICE_CHATMSG = $20;
  YAHOO_SERVICE_GAMELOGON = $28;
  YAHOO_SERVICE_GAMELOGOFF = $29;
  YAHOO_SERVICE_GAMEMSG = $2a;
  YAHOO_SERVICE_FILETRANSFER = $46;
  YAHOO_SERVICE_VOICECHAT = $4a;
  YAHOO_SERVICE_NOTIFY = $4b;
  YAHOO_SERVICE_VERIFY = $4c;
  YAHOO_SERVICE_P2PFILEXFER = $4d;
  YAHOO_SERVICE_PEERTOPEER = $4f;
  YAHOO_SERVICE_AUTHRESP = $54;
  YAHOO_SERVICE_LIST = $55;
  YAHOO_SERVICE_AUTH = $57;
  YAHOO_SERVICE_ADDBUDDY = $83;
  YAHOO_SERVICE_REMBUDDY = $84;
  YAHOO_SERVICE_IGNORECONTACT = $85;
  YAHOO_SERVICE_REJECTCONTACT = $86;

  YAHOO_SERVICE_Y6GAMES = $b7;
  YAHOO_SERVICE_PICCHKSUM = $bd;
  YAHOO_SERVICE_PICTURE = $be;
  YAHOO_SERVICE_PICUPDATE = $c1;
  YAHOO_SERVICE_PICUPLOAD = $c2;
  YAHOO_SERVICE_Y6STATUS = $c6;

  YAHOO_SERVICE_Y7PHOTOS = $d2;
  YAHOO_SERVICE_Y7CONTACT = $d3;
  YAHOO_SERVICE_Y7CHATSESSION = $d4;
  YAHOO_SERVICE_Y7BUDDYAUTH = $d6;
  YAHOO_SERVICE_Y7FILETRSFR = $dc;
  YAHOO_SERVICE_Y7LOGON = $f0;
  YAHOO_SERVICE_Y7LIST = $f1;

  YAHOO_STATUS_AVAILABLE = 0;
  YAHOO_STATUS_BRB = 1;
  YAHOO_STATUS_SERVERACT = 1;
  YAHOO_STATUS_BUSY = 2;
  YAHOO_STATUS_NOTATHOME = 3;
  YAHOO_STATUS_NOTATDESK = 4;
  YAHOO_STATUS_NOTINOFFICE = 5;
  YAHOO_STATUS_ONPHONE = 6;
  YAHOO_STATUS_ONVACATION = 7;
  YAHOO_STATUS_OUTTOLUNCH = 8;
  YAHOO_STATUS_STEPPEDOUT = 9;
  YAHOO_STATUS_INVISIBLE = 12;
  YAHOO_STATUS_CUSTOM = 99;
  YAHOO_STATUS_IDLE = 999;
	YAHOO_STATUS_WEBLOGIN = $5a55aa55;
  YAHOO_STATUS_OFFLINE = $5a55aa56;
  YAHOO_STATUS_TYPING = $16;

  YAHOO_LOGIN_OK = 0;
  YAHOO_LOGIN_SERVER = 1;
  YAHOO_LOGIN_LOGOFF = 2;
  YAHOO_LOGIN_UNAME = 3;
  YAHOO_LOGIN_PASSWD = 13;
  YAHOO_LOGIN_LOCK = 14;
  YAHOO_LOGIN_RELOGON = 44;
  YAHOO_LOGIN_DUPL = 99;
  YAHOO_LOGIN_SOCK = -1;

  YAHOO_MESSAGE_DEFAULT = 0;
  YAHOO_MESSAGE_SERVER = 1;
  YAHOO_MESSAGE_UNKNOWN = 2;
  YAHOO_MESSAGE_AWAY = 4;
  YAHOO_MESSAGE_OFFLINE = 5;

  {* Yahoo style/color directives *}
  YESC = #$1b;
  YAHOO_COLOR_BLACK = YESC +'[30m';
  YAHOO_COLOR_BLUE = YESC +'[31m';
  YAHOO_COLOR_LIGHTBLUE = YESC +'[32m';
  YAHOO_COLOR_GRAY = YESC +'[33m';
  YAHOO_COLOR_GREEN = YESC +'[34m';
  YAHOO_COLOR_PINK = YESC +'[35m';
  YAHOO_COLOR_PURPLE = YESC +'[36m';
  YAHOO_COLOR_ORANGE = YESC +'[37m';
  YAHOO_COLOR_RED = YESC +'[38m';
  YAHOO_COLOR_OLIVE = YESC +'[39m';
  YAHOO_COLOR_ANY = YESC +'[#';
  YAHOO_STYLE_ITALICON = YESC +'[2m';
  YAHOO_STYLE_ITALICOFF = YESC +'[x2m';
  YAHOO_STYLE_BOLDON = YESC +'[1m';
  YAHOO_STYLE_BOLDOFF = YESC +'[x1m';
  YAHOO_STYLE_UNDERLINEON = YESC +'[4m';
  YAHOO_STYLE_UNDERLINEOFF = YESC +'[x4m';
  YAHOO_STYLE_URLON = YESC +'[lm';
  YAHOO_STYLE_URLOFF = YESC +'[xlm';

  YAHOO_DATA_MAX = 65535 +20;
  YAHOO_C080 = #$C0#$80;

  CrLf = #$0D#$0A;

type
  DWord = Longword;

  TYMsgPHRec = packed record
    Name: array[0..3] of Char;        // Header string=YMSG
    Version: DWord;                   // Protocol version
    Length: Word;                     // Length of the DataPacket
    Service: Word;
    Status: DWord;
    SessionID: DWord;
  end;

  TYMsgCoreState = (ymsConnecting, ymsVerify, ymsGetToken, ymsGetCrumb,
    ymsLoggingIn, ymsAuthentication, ymsSignedIn, ymsSignedOut);
  // TODO
  TSocksType = (Ver4, Ver5);
  TYStatus = (
    ysAvailable=YAHOO_STATUS_AVAILABLE,
    ysBeRightBack=YAHOO_STATUS_BRB,
    ysBusy=YAHOO_STATUS_BUSY,
    ysNotAtHome=YAHOO_STATUS_NOTATHOME,
    ysNotAtDesk=YAHOO_STATUS_NOTATDESK,
    ysNotInOffice=YAHOO_STATUS_NOTINOFFICE,
    ysOnPhone=YAHOO_STATUS_ONPHONE,
    ysOnVacation=YAHOO_STATUS_ONVACATION,
    ysOutToLunch=YAHOO_STATUS_OUTTOLUNCH,
    ysSteppedOut=YAHOO_STATUS_STEPPEDOUT,
    ysInvisible=YAHOO_STATUS_INVISIBLE,
    ysCustom=YAHOO_STATUS_CUSTOM,
    ysIdle=YAHOO_STATUS_IDLE,
    ysOffline=YAHOO_STATUS_OFFLINE
  );
  TYBImage = (ybiNone=0, ybiAvatar=1, ybiPicture=2);
  //TYNotify = (ynTyping,ynGame,ynWebcamInvite);

const
  YStatusString: array[0..13] of string= (
    'YAHOO_STATUS_AVAILABLE',
    'YAHOO_STATUS_BRB',
    'YAHOO_STATUS_BUSY',
    'YAHOO_STATUS_NOTATHOME',
    'YAHOO_STATUS_NOTATDESK',
    'YAHOO_STATUS_NOTINOFFICE',
    'YAHOO_STATUS_ONPHONE',
    'YAHOO_STATUS_ONVACATION',
    'YAHOO_STATUS_OUTTOLUNCH',
    'YAHOO_STATUS_STEPPEDOUT',
    'YAHOO_STATUS_INVISIBLE',
    'YAHOO_STATUS_CUSTOM',
    'YAHOO_STATUS_IDLE',
    'YAHOO_STATUS_OFFLINE'
  );  
implementation

end.