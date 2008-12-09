From: David Miller <davem@davemloft.net>
Subject: Re: [patch] sumgem: improve ethtool output with fibre card using
 the internal pcs and a serdes
Date: Tue, 09 Dec 2008 15:39:40 -0800 (PST)
Message-ID: <20081209.153940.253066469.davem@davemloft.net>
References: <20081128000059.GA13712@lemon.iwr.uni-heidelberg.de>
	<20081201.233539.77173438.davem@davemloft.net>
	<20081204113434.GC15643@lemon.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hermann.Lauer@iwr.uni-heidelberg.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45264
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752357AbYLIXjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 18:39:39 -0500
In-Reply-To: <20081204113434.GC15643@lemon.iwr.uni-heidelberg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hermann Lauer <Hermann.Lauer@iwr.uni-heidelberg.de>
Date: Thu, 4 Dec 2008 12:34:34 +0100

> Attached is a patch which improves the output of ethtool (see below) to
> some sensefull values with a sungem fibre card which uses the 
> sungem interal pcs connected to a serdes chip. The seriallink case
> in the driver is untouched.
> 
> Most values are hardcoded, because gigabit fibre autoneg is anyways
> limited and the driver don't really support much at the moment
> with that hardware.
> 
> Please consider for inclusion or comment.
> Thanks,
>   Hermann

Patch applied, thanks Hermann.
