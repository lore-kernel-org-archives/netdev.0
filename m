From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 1/2] chelsio: T200 support
Date: Mon, 27 Nov 2006 17:32:48 -0800
Message-ID: <20061127173248.1548fb4e.akpm@osdl.org>
References: <Pine.LNX.4.64.0611131408010.32659@potato.cts.ucla.edu>
	<455A49D7.4050106@garzik.org>
	<20061114153725.730fcd6d@freekitty>
	<Pine.LNX.4.64.0611141540110.3416@potato.cts.ucla.edu>
	<20061115170320.5078073a@freekitty>
	<20061115190903.d61be44f.akpm@osdl.org>
	<20061115213532.0d2350ba@localhost.localdomain>
	<20061115215206.6bee3534.akpm@osdl.org>
	<20061117172057.61015224@zqx3.pdx.osdl.net>
	<20061127231738.GA19096@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:62104 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1758640AbWK1Bdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Nov 2006 20:33:32 -0500
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20061127231738.GA19096@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 28 Nov 2006 00:17:38 +0100
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Stephen Hemminger <shemminger@osdl.org> :
> > This patch is experimental, it applies after the earlier 6 chelsio cleanup
> > patches. Tested on a pair of T210 board's.
> 
> The whole serie is stored as branch 'chelsio' at:
> git://electric-eye.fr.zoreil.com/home/romieu/linux/linux-2.6-out/.git chelsio

I think you meant
git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git#chelsio

> I have hand-edited a few patches to convert some spaces/tabs.

I'll try adding this to -mm.

I hope someone knows what's happening with this driver, because I've
seriously lost the plot.

