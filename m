From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/9] sky2: skb recycling
Date: Wed, 17 Jun 2009 18:51:21 -0700 (PDT)
Message-ID: <20090617.185121.71437624.davem@davemloft.net>
References: <20090617173031.703636683@vyatta.com>
	<20090617173140.244124173@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51062
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753277AbZFRBvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 21:51:18 -0400
In-Reply-To: <20090617173140.244124173@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 17 Jun 2009 10:30:38 -0700

> This patch implements skb recycling. It reclaims transmitted skb's
> for use in the receive ring.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
