From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rfkill: Make rfkill->name const
Date: Tue, 05 Jun 2007 00:05:34 -0700 (PDT)
Message-ID: <20070605.000534.18578478.davem@davemloft.net>
References: <200706012020.44112.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dtor@insightbb.com, netdev@vger.kernel.org
To: ivdoorn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56979
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762161AbXFEHFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 03:05:19 -0400
In-Reply-To: <200706012020.44112.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivo van Doorn <ivdoorn@gmail.com>
Date: Fri, 1 Jun 2007 20:20:43 +0200

> The rfkill name can be made const safely,
> this makes the compiler happy when drivers make
> it point to some const string used elsewhere.
> 
> Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

Patch applied, thanks.
