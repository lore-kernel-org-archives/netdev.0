From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Fri, 04 Jul 2008 14:45:26 +0100
Message-ID: <1215179126.10393.771.camel@pmac.infradead.org>
References: <20080703020236.adaa51fa.akpm@linux-foundation.org>
	 <20080703205548.D6E5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <486CC440.9030909@garzik.org>
	 <Pine.LNX.4.64.0807031353030.11033@blonde.site>
	 <s5hmykxc3ja.wl%tiwai@suse.de>
	 <1215177471.10393.753.camel@pmac.infradead.org>
	 <s5hej69lqzk.wl%tiwai@suse.de>  <486E28BB.1030205@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Takashi Iwai <tiwai@suse.de>, Hugh Dickins <hugh@veritas.com>,
	KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>,
	mchan@broadcom.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:58034 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754218AbYGDNpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 09:45:36 -0400
In-Reply-To: <486E28BB.1030205@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-07-04 at 09:42 -0400, Jeff Garzik wrote:
> mkinitrd and similar scripts must be updated, so that drivers that 
> worked prior to dwmw2's changes will continue to work after dwmw2's
> changes.

> If you fail to update some script somewhere, then the driver will be 
> copied into the initramfs, but not the firmware, with obvious results.

No, mkinitrd works fine, because a whole boatload of drivers _already_
require it to work that way and have done for a long time.

Either you are severely mistaken, or you are being deliberately
misleading.

-- 
dwmw2

