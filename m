From: Arthur Kepner <akepner@sgi.com>
Subject: Re: [PATCH] fix "ethtool -S" for tg3
Date: Wed, 12 May 2004 13:00:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.SGI.4.56.0405121256510.7328714@neteng.engr.sgi.com>
References: <Pine.SGI.4.56.0405111251080.7038576@neteng.engr.sgi.com>
 <20040512120810.464aaee6.davem@redhat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1072017398-1259774184-1084392024=:7328714"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040512120810.464aaee6.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---1072017398-1259774184-1084392024=:7328714
Content-Type: TEXT/PLAIN; charset=US-ASCII


On Wed, 12 May 2004, David S. Miller wrote:

> .....
> Patch doesn't apply, your mail client turned all the tabs
> into spaces.  Use attachments if necessary, thanks.
>

OK. Attached is the patch.

--

Arthur
---1072017398-1259774184-1084392024=:7328714
Content-Type: TEXT/PLAIN; charset=US-ASCII; name=ethtool-S-patch
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.SGI.4.56.0405121300240.7328714@neteng.engr.sgi.com>
Content-Description: ethtool -S patch
Content-Disposition: attachment; filename=ethtool-S-patch

LS0tIGxpbnV4Lm9yaWcvZHJpdmVycy9uZXQvdGczLmMJMjAwNC0wNS0xMiAx
Mjo0MTo1OC4wMDAwMDAwMDAgLTA3MDANCisrKyBsaW51eC9kcml2ZXJzL25l
dC90ZzMuYwkyMDA0LTA1LTEyIDEyOjQ3OjA2LjAwMDAwMDAwMCAtMDcwMA0K
QEAgLTYyODQsNyArNjI4NCw3IEBADQogCQkJCSAgIHN0cnVjdCBldGh0b29s
X3N0YXRzICplc3RhdHMsIHU2NCAqdG1wX3N0YXRzKQ0KIHsNCiAJc3RydWN0
IHRnMyAqdHAgPSBkZXYtPnByaXY7DQotCW1lbWNweSh0bXBfc3RhdHMsICZ0
cC0+ZXN0YXRzLCBzaXplb2YodHAtPmVzdGF0cykpOw0KKwltZW1jcHkodG1w
X3N0YXRzLCB0ZzNfZ2V0X2VzdGF0cyh0cCksIHNpemVvZih0cC0+ZXN0YXRz
KSk7DQogfQ0KIA0KIHN0YXRpYyBpbnQgdGczX2lvY3RsKHN0cnVjdCBuZXRf
ZGV2aWNlICpkZXYsIHN0cnVjdCBpZnJlcSAqaWZyLCBpbnQgY21kKQ0K

---1072017398-1259774184-1084392024=:7328714--
