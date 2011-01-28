From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 v2 5/7] ixgbe: DDP last buffer size work around
Date: Fri, 28 Jan 2011 13:45:08 -0800 (PST)
Message-ID: <20110128.134508.115934259.davem@davemloft.net>
References: <1296217743-30093-6-git-send-email-jeffrey.t.kirsher@intel.com>
	<20110128.115100.226772144.davem@davemloft.net>
	<4C5E6457CD7911469A07260381288C28CBE83195@orsmsx502.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: amir.hanania@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50346
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751494Ab1A1Vod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jan 2011 16:44:33 -0500
In-Reply-To: <4C5E6457CD7911469A07260381288C28CBE83195@orsmsx502.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Hanania, Amir" <amir.hanania@intel.com>
Date: Fri, 28 Jan 2011 13:36:15 -0800

> Sorry I missed your mail from last night.
> 
> You are right, it should be bufflen, which is 4096 and not PAGE_SIZE.
> 
> I will fix that and resubmit.

Thanks for looking into this.
