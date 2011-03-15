From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] be2net: Fix UDP packet detected status in
 RX compl
Date: Tue, 15 Mar 2011 14:57:20 -0700 (PDT)
Message-ID: <20110315.145720.179924404.davem@davemloft.net>
References: <fa0d690e-8b0a-4608-be17-d65c22246f37@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@emulex.com
To: padmanabh.ratnakar@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42318
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758717Ab1COV4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 17:56:43 -0400
In-Reply-To: <fa0d690e-8b0a-4608-be17-d65c22246f37@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Date: Tue, 15 Mar 2011 15:59:01 +0530

> Status of UDP packet detection not getting populated in RX completion
> structure. This is required in csum_passed() routine.
> 
> Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied, thanks.
