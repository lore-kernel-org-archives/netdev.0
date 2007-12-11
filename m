From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] XFRM: assorted IPsec fixups
Date: Tue, 11 Dec 2007 02:22:02 -0800 (PST)
Message-ID: <20071211.022202.208850272.davem@davemloft.net>
References: <20071207171116.18151.42328.stgit@flek.americas.hpqcorp.net>
	<1197059769.3183.16.camel@dhcp231-215.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, netdev@vger.kernel.org, linux-audit@redhat.com,
	selinux@tycho.nsa.gov
To: eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48352
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751328AbXLKKWC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 05:22:02 -0500
In-Reply-To: <1197059769.3183.16.camel@dhcp231-215.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Paris <eparis@redhat.com>
Date: Fri, 07 Dec 2007 15:36:08 -0500

> 
> On Fri, 2007-12-07 at 12:11 -0500, Paul Moore wrote:
> > This patch fixes a number of small but potentially troublesome things in the
> > XFRM/IPsec code:
...
> > Signed-off-by: Paul Moore <paul.moore@hp.com>
> 
> Acked-by: Eric Paris <eparis@redhat.com>
> 
> although it does make me wonder why audit_log_start doesn't just check
> audit_enabled itself....   Anyway, this patch looks good.

I want to apply this but it doesn't apply cleanly to
net-2.6.25 right now, could you respin this Paul?

Thanks.
