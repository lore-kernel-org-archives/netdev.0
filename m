From: =?iso-8859-1?q?francois=20donzet?= <fdonzet@yahoo.fr>
Subject: skb->len <=76
Date: Thu, 13 Nov 2003 09:35:56 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031113083556.29025.qmail@web25207.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Hello,=20

In the tcp_v4_checksum_init function, the statement
if(skb->len<=3D76) appears.=20

What does this size of 76 bytes represent ? And why it
is a separate case from other packets?

I dont think it is an arbitraty value ;)

Thanks

___________________________________________________________
Do You Yahoo!? -- Une adresse @yahoo.fr gratuite et en fran=E7ais !
Yahoo! Mail : http://fr.mail.yahoo.com
