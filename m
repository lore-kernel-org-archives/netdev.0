From: "Andre Tomt" <andre@tomt.net>
Subject: RE: unable to add ipv6 default route in 2.4.21-rc1 + latest bkbits.net pieces
Date: Sun, 4 May 2003 11:21:04 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <005701c3121e$7cc46370$0a01ff0a@slurv>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
In-Reply-To: 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Replying to myself here.

And again.

Have some more information now. It seems, I cannot use 2001:730:f:3:: as
an ordinary unicast global address anymore? At least not as a default
gateway. Adding a default route pointing to 2001:730:f:3::1 works just
fine, but why did :0000 break?

PS! I'm not subscribed to this list, so CC's would be nice. I forgot to
mention this earlier too.

--=20
Cheers,
Andr=E9 Tomt
andre@tomt.net
