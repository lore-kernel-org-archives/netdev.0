From: David Miller <davem@davemloft.net>
Subject: Re: Extensible hashing and RCU
Date: Thu, 22 Feb 2007 03:44:04 -0800 (PST)
Message-ID: <20070222.034404.126578034.davem@davemloft.net>
References: <20070221.053721.112287244.davem@davemloft.net>
	<17884.53809.880275.142372@robur.slu.se>
	<20070222114105.GA12844@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, dada1@cosmosbay.com,
	johnpol@2ka.mipt.ru, akepner@sgi.com, linux@horizon.com,
	netdev@vger.kernel.org, bcrl@kvack.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42058
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933041AbXBVLoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 06:44:06 -0500
In-Reply-To: <20070222114105.GA12844@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: Thu, 22 Feb 2007 12:41:05 +0100

> >  With 100k flows we typically see an aver depth 1.3 and a max depth 4. Right 
> 
> This includes full srcport:dstport?

Yes.
