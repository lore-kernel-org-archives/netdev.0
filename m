From: Peter Bieringer <pb@bieringer.de>
Subject: Re: why cannot unload ipv6 module ?
Date: Thu, 14 Nov 2002 20:54:07 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <18430000.1037303647@localhost>
References: <001801c28bb8$cd749c50$6c06a8c0@zhengjp>
 <20021114.180104.77076139.yoshfuji@linux-ipv6.org>
 <000e01c28bd1$ffdaf2c0$6c06a8c0@zhengjp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="==========1825439384=========="
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <000e01c28bd1$ffdaf2c0$6c06a8c0@zhengjp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--==========1825439384==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline



--On Thursday, November 14, 2002 07:35:57 PM +0800 Zheng Jianping
<zjp@iscas.ac.cn> wrote:

> 
>> > I complie IPv6 as module and install it. But when I try to
>> > unload it, I
> failed.
>> > How can I make IPv6 module unload?
>> 
>> unloading ipv6 module is not supported.
>> 
> Can I modify the IPv6 source code to make unloading supported?
> If yes, how to modify it?

A little bit offtopic:

does anyone know the state about the work on the ipv*4* module? There
was some rumour some months ago.

Would be nice if some day in the future an IPv6-only Linux box would
be possible.

        Peter

---
Dr. Peter Bieringer
mailto: pb at bieringer dot de
http://www.bieringer.de/pb/
Key 0x958F422D : B501 24F4 9418 23E2 C0F3  F833 7B57 AA7B 958F 422D
--==========1825439384==========
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.0 (GNU/Linux)

iD8DBQE90/9te1eqe5WPQi0RAk+yAKDBU9xqItqXk9NMJachzbTvWGEp3ACg61Kq
ON9EdhVXbHzuvP1RaSpFvTE=
=1fDb
-----END PGP SIGNATURE-----

--==========1825439384==========--
