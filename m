From: Jeff Garzik <jeff@garzik.org>
Subject: wireless (was Re: 2.6.18 -mm merge plans)
Date: Sun, 4 Jun 2006 21:06:36 -0400
Message-ID: <20060605010636.GB17361@havoc.gtf.org>
References: <20060604135011.decdc7c9.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:37775 "EHLO havoc.gtf.org")
	by vger.kernel.org with ESMTP id S932367AbWFEBGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2006 21:06:37 -0400
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060604135011.decdc7c9.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 04, 2006 at 01:50:11PM -0700, Andrew Morton wrote:
> acx1xx-wireless-driver.patch
> fix-tiacx-on-alpha.patch
> tiacx-fix-attribute-packed-warnings.patch
> tiacx-pci-build-fix.patch
> tiacx-ia64-fix.patch
> 
>   It is about time we did something with this large and presumably useful
>   wireless driver.

I've never had technical objections to merging this, just AFAIK it had a
highly questionable origin, namely being reverse-engineered in a
non-clean-room environment that might leave Linux legally vulnerable.

If we can clear that hurdle, by all means pass it on to John Linville
and get it moving towards upstream.

	Jeff



