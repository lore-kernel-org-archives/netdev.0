From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 0/2] netxen: fix debug tools and some corner cases
Date: Wed, 02 Dec 2009 20:33:10 -0800 (PST)
Message-ID: <20091202.203310.67919408.davem@davemloft.net>
References: <1259804779-23091-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36649
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752115AbZLCEdD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 23:33:03 -0500
In-Reply-To: <1259804779-23091-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Wed,  2 Dec 2009 17:46:17 -0800

>  Sending you two patches.
> 
>  1) Fixes debug tools access: 
> 	When debug tools need to access resources in unmapped regions,
>         map these on the fly in order to complete read/write request.
> 
>  2) This fixes failure cases of fimware recovery module and
>     and some corner cases.

Both applied to net-next-2.6, thanks!
