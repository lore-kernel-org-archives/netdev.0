From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] netdev: bfin_mac: enable VLAN support in Blackfin
 MAC driver
Date: Thu, 08 Jan 2009 11:29:27 -0800 (PST)
Message-ID: <20090108.112927.143913755.davem@davemloft.net>
References: <1231344879-26069-3-git-send-email-cooloney@kernel.org>
	<20090108.105531.176161465.davem@davemloft.net>
	<8bd0f97a0901081101t6fdfa485rbd7ccc4e47691ddb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cooloney@kernel.org, jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, graf.yang@analog.com
To: vapier.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49937
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755181AbZAHT3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 14:29:25 -0500
In-Reply-To: <8bd0f97a0901081101t6fdfa485rbd7ccc4e47691ddb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Mike Frysinger" <vapier.adi@gmail.com>
Date: Thu, 8 Jan 2009 14:01:49 -0500

> > We can get VLAN packets received and sent, using AF_PACKET
> > sockets, for example.  The chip should still respect those
> > even if VLAN proper is not being utilized.
> 
> any tips on doing that ?

No, sorry.
