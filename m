From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6][atm]: remove IRQF_DISABLED in combination
 with IRQF_SHARED
Date: Mon, 12 Jul 2010 20:34:01 -0700 (PDT)
Message-ID: <20100712.203401.209982598.davem@davemloft.net>
References: <201007101342.o6ADg2wx019157@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41443
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752630Ab0GMDdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jul 2010 23:33:46 -0400
In-Reply-To: <201007101342.o6ADg2wx019157@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Date: Sat, 10 Jul 2010 09:42:02 -0400

> From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
> 
> commit 2fae0433cf7febc4b69ff58730de1ca412846743
> Author: chas williams - CONTRACTOR <chas@relax.cmf.nrl.navy.mil>
> Date:   Sat Jul 10 09:38:05 2010 -0400
> 
>     [atm]: remove IRQF_DISABLED in combination with IRQF_SHARED
>     
>     Signed-off-by: Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>

Applied.
