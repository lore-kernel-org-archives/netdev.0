From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH 0/13] bnx2x: Buf fixes and enhancements
Date: Mon, 19 Apr 2010 09:06:11 +0300
Message-ID: <1271657171.27125.19.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1271602046.27235.165.camel@lb-tlvb-vladz>
 <20100418.210723.71102685.davem@davemloft.net>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Vladislav Zolotarov" <vladz@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3657 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751350Ab0DSGGY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Apr 2010 02:06:24 -0400
In-Reply-To: <20100418.210723.71102685.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-04-18 at 21:07 -0700, David Miller wrote:
> From: "Vladislav Zolotarov" <vladz@broadcom.com>
> Date: Sun, 18 Apr 2010 17:47:26 +0300
> 
> > Dave, hi.
> > Pls., apply the following series of patches.
> > It includes a few bug fixes and enhancements.
> 
> Several of these patches are inappropriate or need corrections, and
> you also have not specified where you want these patches applied
> (net-2.6 or net-next-2.6)
> 

We will re-submit the path series with the following fixes:
- Omitting patch 11 (disabling LRO and leaving only GRO on XEN kernel on
compile time)
- restructuring patch 2 (using generic infrastructures for VPD-R-V0
access)
- Better description - especially on email 0...
- I'm sending another email regrading the number of queues on 32 bits
kernel.


Thanks for all the inputs,
Eilon


