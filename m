From: Milan Kocian <milon@wq.cz>
Subject: Re: sky2 tx watchdog timeout with 1Gb speed
Date: Mon, 5 Dec 2011 13:47:25 +0100
Message-ID: <20111205124725.GA19385@ntm.wq.cz>
References: <20111120232118.GA29748@ntm.wq.cz>
 <20111121160543.2ae9c04c@nehalam.linuxnetplumber.net>
 <20111122094234.GA28500@ntm.wq.cz>
 <20111126161513.GA5299@ntm.wq.cz>
 <20111126170331.744025f1@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srw1.wq.cz ([80.92.240.72]:58658 "EHLO srw1.wq.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756344Ab1LEMre (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Dec 2011 07:47:34 -0500
Content-Disposition: inline
In-Reply-To: <20111126170331.744025f1@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 26, 2011 at 05:03:31PM -0800, Stephen Hemminger wrote:
> 
> I think the problem might be that the board doesn't really have all the DMA pins
> wired. You might try enabling iommu, or limiting to <4G of memory.

hello stephen,

you are probably right. I found that with this mb (Gigabyte GA-965GM-S2) was
more problems with linux. So I replaced this old crap with new one :-).
Many thanks for your time.

Best regards,

-- 
Milan Kocian
