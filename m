From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [net PATCH v2] 8139cp: Add dma_mapping_error checking
Date: Sun, 28 Jul 2013 19:34:50 -0400
Message-ID: <20130728233449.GA15543@neilslaptop.think-freely.org>
References: <1374516882-19131-1-git-send-email-nhorman@tuxdriver.com>
 <1374848918-17183-1-git-send-email-nhorman@tuxdriver.com>
 <20130726200630.GA20690@electric-eye.fr.zoreil.com>
 <20130726204245.GD11633@hmsreliant.think-freely.org>
 <20130726212403.GA25674@electric-eye.fr.zoreil.com>
 <20130728104052.GA9876@neilslaptop.think-freely.org>
 <20130728213419.GA14253@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42056 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751313Ab3G1XfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jul 2013 19:35:08 -0400
Content-Disposition: inline
In-Reply-To: <20130728213419.GA14253@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 28, 2013 at 11:34:19PM +0200, Francois Romieu wrote:
> Neil Horman <nhorman@tuxdriver.com> :
> [...]
> > So you agree with the patch as it stands?
> 
> This part, yes.
> 
> However I still see a need for a rx_dropped increase.
> 
Very well, I'll take another look tomorrow morning
Neil

> -- 
> Ueimor
> 
