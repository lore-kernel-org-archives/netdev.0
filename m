From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] bnx2x: fix UDP csum offload
Date: Sat, 23 Apr 2011 15:16:05 -0700 (PDT)
Message-ID: <20110423.151605.193705773.davem@davemloft.net>
References: <1303580687.2708.40.camel@lb-tlvb-dmitry.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	eilong@broadcom.com, vladz@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36136
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757268Ab1DWWQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Apr 2011 18:16:39 -0400
In-Reply-To: <1303580687.2708.40.camel@lb-tlvb-dmitry.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Sat, 23 Apr 2011 20:44:46 +0300

> From: Vladislav Zolotarov <vladz@broadcom.com>
> 
> Fixed packets parameters for FW in UDP checksum offload flow.
> 
> Do not dereference TCP headers on non TCP frames.
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>  
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thanks everyone!
