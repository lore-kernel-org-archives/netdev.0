From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH 2/3] Security: Implement disablenetwork semantics. (v4)
Date: Tue, 12 Jan 2010 09:28:43 -0500
Message-ID: <32558.1263306523@localhost>
References: <alpine.LRH.2.00.1001110811350.25601@tundra.namei.org> <20100110215409.GA3705@heat> <20100110215848.GA26609@elf.ucw.cz> <5768.1263264853@localhost>
            <20100112075927.GA24256@atrey.karlin.mff.cuni.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1263306523_4979P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Michael Stone <michael@laptop.org>,
	James Morris <jmorris@namei.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Am?rico Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Al Viro <viro@ZenIV.linux.org.uk>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754010Ab0ALOad@vger.kernel.org>
In-Reply-To: Your message of "Tue, 12 Jan 2010 08:59:27 +0100."
             <20100112075927.GA24256@atrey.karlin.mff.cuni.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1263306523_4979P
Content-Type: text/plain; charset=us-ascii

On Tue, 12 Jan 2010 08:59:27 +0100, Pavel Machek said:

> Well, maybe, but mailer system where first user starts is as a daemon
> makes sense...

Does it?  How do you get port 25 open for listening if the first user isn't
root?  Most *actual* schemes to "launch at first use" that require privs for
something have used inetd or similar - that program exists for a *reason*.

--==_Exmh_1263306523_4979P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFLTIcbcC3lWbTT17ARAr8PAJ94bDdQldxM7RZrZfTZGf16tCxRBQCgodDB
rBzAtNDSU79QFaso6ka4onU=
=Sa8Z
-----END PGP SIGNATURE-----

--==_Exmh_1263306523_4979P--
