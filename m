From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [net PATCH v2] 8139cp: Add dma_mapping_error checking
Date: Sun, 28 Jul 2013 23:34:19 +0200
Message-ID: <20130728213419.GA14253@electric-eye.fr.zoreil.com>
References: <1374516882-19131-1-git-send-email-nhorman@tuxdriver.com>
 <1374848918-17183-1-git-send-email-nhorman@tuxdriver.com>
 <20130726200630.GA20690@electric-eye.fr.zoreil.com>
 <20130726204245.GD11633@hmsreliant.think-freely.org>
 <20130726212403.GA25674@electric-eye.fr.zoreil.com>
 <20130728104052.GA9876@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:34889 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751650Ab3G1Ved (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jul 2013 17:34:33 -0400
Content-Disposition: inline
In-Reply-To: <20130728104052.GA9876@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman <nhorman@tuxdriver.com> :
[...]
> So you agree with the patch as it stands?

This part, yes.

However I still see a need for a rx_dropped increase.

-- 
Ueimor
