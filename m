From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v10] tilegx network driver: initial support
Date: Thu, 7 Jun 2012 21:50:19 +0100
Message-ID: <1339102219.2770.21.camel@bwh-desktop.uk.solarflarecom.com>
References: <4FCFA312.4020505@tilera.com>
	 <20120606.115440.1245419453265419850.davem@davemloft.net>
	 <201206072031.q57KV0NG029301@farm-0023.internal.tilera.com>
	 <20120607.133900.1764130639940088009.davem@davemloft.net>
	 <4FD11292.10700@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <eric.dumazet@gmail.com>,
	<arnd@arndb.de>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FD11292.10700@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-06-07 at 16:44 -0400, Chris Metcalf wrote:
> On 6/7/2012 4:39 PM, David Miller wrote:
> > From: Chris Metcalf <cmetcalf@tilera.com>
> > Date: Fri, 6 Apr 2012 16:42:03 -0400
> >
> >> Date: Fri, 6 Apr 2012 16:42:03 -0400
> > You did not commit this file on April 6th.
> >
> > Please don't use the date emitted by the GIT tools, just
> > let the email use the natural correct date which is the
> > one at the time you send the email out.
> >
> > Otherwise your patch gets misordered as automated tools like
> > patchwork think this file should go all the way at the back
> > of the patch queue because of it's old date relative to
> > other pending patches.
> 
> Yes, when I use "git rebase" to merge changes into the earlier patch, this
> is the behavior I see.  I don't know if there's some way to tell git to
> take the date on the later change instead when I "squash" them.
[...]

git commit --amend --date="$(date)"

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
