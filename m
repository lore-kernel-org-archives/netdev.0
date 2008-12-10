From: David Miller <davem@davemloft.net>
Subject: Re: [patch 5/7] bonding: remove duplicate declarations
Date: Tue, 09 Dec 2008 23:09:56 -0800 (PST)
Message-ID: <20081209.230956.177197939.davem@davemloft.net>
References: <20081209200750.490739902@eitzenberger.org>
	<20081209201449.891457437@eitzenberger.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org
To: holger@eitzenberger.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48294
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754491AbYLJHJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 02:09:55 -0500
In-Reply-To: <20081209201449.891457437@eitzenberger.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: holger@eitzenberger.org
Date: Tue, 09 Dec 2008 21:07:55 +0100

> Remove some declarations from bonding.c as they are declared in bonding.h
> already.
> 
> Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Applied.
