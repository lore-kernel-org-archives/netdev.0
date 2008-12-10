From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/7] bonding: add and use bond_is_lb()
Date: Tue, 09 Dec 2008 23:07:20 -0800 (PST)
Message-ID: <20081209.230720.114054750.davem@davemloft.net>
References: <20081209200750.490739902@eitzenberger.org>
	<20081209201444.964037720@eitzenberger.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org
To: holger@eitzenberger.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39289
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753607AbYLJHHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 02:07:19 -0500
In-Reply-To: <20081209201444.964037720@eitzenberger.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: holger@eitzenberger.org
Date: Tue, 09 Dec 2008 21:07:51 +0100

> Introduce and use bond_is_lb(), it is usefull to shorten the repetitive
> check for either ALB or TLB mode.
> 
> Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Applied.
