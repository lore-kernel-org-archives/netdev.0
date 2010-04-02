From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Added GRO support
Date: Thu, 01 Apr 2010 19:46:04 -0700 (PDT)
Message-ID: <20100401.194604.248174632.davem@davemloft.net>
References: <1270122573.22693.6.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-3
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, vladz@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60263
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758120Ab0DBCqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 22:46:03 -0400
In-Reply-To: <1270122573.22693.6.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Thu, 1 Apr 2010 14:49:33 +0300

> Adding GRO support on top of the HW LRO (TPA) support –
> there is no measurable performance drawback of adding GRO
> on top of it, and it allows better performance when LRO (TPA)
> is turned off for virtualization or bridging.
> 
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thank you.
