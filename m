From: Peter Bieringer <pb@bieringer.de>
Subject: Re: How to get IPv6 interface?
Date: Tue, 26 Nov 2002 20:08:36 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <55380000.1038337716@worker.muc.bieringer.de>
References: <003201c29525$cd933360$6c06a8c0@zhengjp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="==========903190887=========="
Cc: Zheng Jianping <zjp@iscas.ac.cn>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <003201c29525$cd933360$6c06a8c0@zhengjp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--==========903190887==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline



--On Tuesday, November 26, 2002 04:28:31 PM +0800 Zheng Jianping
<zjp@iscas.ac.cn> wrote:

> My linux kernel is 2.4.7.10, how to get the information of all IPv6
> interfaces, including the interfaces index, flags,name and
> address,etc ?

Userspace: ip -6 addr

        Peter
---
Dr. Peter Bieringer
mailto: pb at bieringer dot de
http://www.bieringer.de/pb/
Key 0x958F422D : B501 24F4 9418 23E2 C0F3  F833 7B57 AA7B 958F 422D
--==========903190887==========
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.0 (GNU/Linux)

iD8DBQE948a2e1eqe5WPQi0RAn3eAJ98CB5Dk1YrxJ1NyZSk/k8tKrelJQCfaQZ+
xalwM92/OLMAt4Gjq2GSVY8=
=bXez
-----END PGP SIGNATURE-----

--==========903190887==========--
