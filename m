From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [2.6 patch] irda/qos.c: remove an unused function
Date: Fri, 29 Oct 2004 01:57:43 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041028235743.GQ3207@stusta.de>
References: <20041028222238.GP3207@stusta.de> <20041028162737.3d2debdf.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; x-action=pgp-signed
Cc: dagb@cs.uit.no, jt@hpl.hp.com, irda-users@lists.sourceforge.net,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20041028162737.3d2debdf.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Thu, Oct 28, 2004 at 04:27:37PM -0700, David S. Miller wrote:
> 
> Ok, it looks like this whole enormous set of diffs are corrupted.
> They all are "patches of a patch" which won't apply correctly.
> 
> If you're going to send such a huge set of diffs out, please test
> them our and make sure they do apply properly before mailing
> them out.

I did test that they apply and compile.

Shit. It seems gpg escapes all minus signs when doing an inline 
signature of the message.

I'll resend the patches, thanks for the note.

> Thanks.

cu
Adrian

- -- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQFBgYd3mfzqmE8StAARAsQ+AJ9OB3lnny2AKUj2y42n3v6zm80CcACgjAoA
OP6vfM8VeyhUbnsKvdqVgzA=
=OJSY
-----END PGP SIGNATURE-----
