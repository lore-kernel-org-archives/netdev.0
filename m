From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [PATCH] OpenBSD Networking-related randomization port
Date: Mon, 31 Jan 2005 17:50:25 +0100
Message-ID: <20050131165025.GN18316@stusta.de>
References: <1106932637.3778.92.camel@localhost.localdomain> <20050128100229.5c0e4ea1@dxpl.pdx.osdl.net> <1106937110.3864.5.camel@localhost.localdomain> <20050128105217.1dc5ef42@dxpl.pdx.osdl.net> <1106944492.3864.30.camel@localhost.localdomain> <1106945266.7776.41.camel@laptopd505.fenrus.org> <200501290915.j0T9FkVY012948@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@infradead.org>,
	Lorenzo =?iso-8859-1?Q?Hern=E1ndez_Garc=EDa-Hierro?=
	<lorenzo@gnu.org>, Stephen Hemminger <shemminger@osdl.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Chris Wright <chrisw@osdl.org>, netdev@oss.sgi.com,
	Hank Leininger <hlein@progressive-comp.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261246AbVAaQuf@vger.kernel.org>
To: Valdis.Kletnieks@vt.edu
Content-Disposition: inline
In-Reply-To: <200501290915.j0T9FkVY012948@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 29, 2005 at 04:15:43AM -0500, Valdis.Kletnieks@vt.edu wrote:
> On Fri, 28 Jan 2005 21:47:45 +0100, Arjan van de Ven said:
> 
> > as for obsd_get_random_long().. would it be possible to use the
> > get_random_int() function from the patches I posted the other day? They
> > use the existing random.c infrastructure instead of making a copy...
> > 
> > I still don't understand why you need a obsd_rand.c and can't use the
> > normal random.c
> 
> Note that obsd_rand.c started off life as a BSD-licensed file - I was told
> that was a show-stopper when I submitted basically the same patch a while back.
>...

At least the three clause BSD license is GPL compatible.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
