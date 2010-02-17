From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8]: Bug fixes and new FW patch series
Date: Wed, 17 Feb 2010 13:44:51 -0800 (PST)
Message-ID: <20100217.134451.10225453.davem@davemloft.net>
References: <1266408196.25691.841.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57276
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757397Ab0BQVog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 16:44:36 -0500
In-Reply-To: <1266408196.25691.841.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Wed, 17 Feb 2010 14:03:16 +0200

> Dave, hi.
> Pls., apply the following series of patches.
> It includes a few bugs fixes and a few FW.
> 
> The patches may also be found at
> http://linux.broadcom.com/eilong/1.52.1-6

All applied, but please coordinate better with changes coming in via
your colleages.

Patch #6 would not apply cleanly because the firmware/Makefile is
different due to the bnx2 driver firmware updates made yesterday.

I fixed it up by hand, but in the future apply patches that apply
cleanly to the current tree.

Thanks.
