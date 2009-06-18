From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/9] sky2: PCI irq issues
Date: Wed, 17 Jun 2009 18:50:44 -0700 (PDT)
Message-ID: <20090617.185044.179919862.davem@davemloft.net>
References: <20090617173031.703636683@vyatta.com>
	<20090617173139.699221446@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51049
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752658AbZFRBul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 21:50:41 -0400
In-Reply-To: <20090617173139.699221446@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 17 Jun 2009 10:30:34 -0700

> Add some read's to avoid any PCI posting issues when controlling
> irq's.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
