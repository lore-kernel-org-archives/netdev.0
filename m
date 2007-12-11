From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] XFRM: assorted IPsec fixups
Date: Tue, 11 Dec 2007 09:05:05 -0500
Message-ID: <200712110905.06312.paul.moore@hp.com>
References: <20071207171116.18151.42328.stgit@flek.americas.hpqcorp.net> <1197059769.3183.16.camel@dhcp231-215.rdu.redhat.com> <20071211.022202.208850272.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: eparis@redhat.com, netdev@vger.kernel.org, linux-audit@redhat.com,
	selinux@tycho.nsa.gov
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:48623 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111AbXLKOFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 09:05:15 -0500
In-Reply-To: <20071211.022202.208850272.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 11 December 2007 5:22:02 am David Miller wrote:
> From: Eric Paris <eparis@redhat.com>
> Date: Fri, 07 Dec 2007 15:36:08 -0500
>
> > On Fri, 2007-12-07 at 12:11 -0500, Paul Moore wrote:
> > > This patch fixes a number of small but potentially troublesome things
> > > in the XFRM/IPsec code:
>
> ...
>
> > > Signed-off-by: Paul Moore <paul.moore@hp.com>
> >
> > Acked-by: Eric Paris <eparis@redhat.com>
> >
> > although it does make me wonder why audit_log_start doesn't just check
> > audit_enabled itself....   Anyway, this patch looks good.
>
> I want to apply this but it doesn't apply cleanly to
> net-2.6.25 right now, could you respin this Paul?

Sure, sorry about that.  I wasn't certain who was going to pick this up so I 
just backed again Linus' tree.  I'll get a respun version out later today.

Thanks.

-- 
paul moore
linux security @ hp
