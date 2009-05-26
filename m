From: David Miller <davem@davemloft.net>
Subject: Re: sparc: struct device - replace bus_id with dev_name(),
 dev_set_name()
Date: Tue, 26 May 2009 02:30:55 -0700 (PDT)
Message-ID: <20090526.023055.41899055.davem@davemloft.net>
References: <1239898912.17211.7.camel@poy>
	<20090416.155643.06066521.davem@davemloft.net>
	<ac3eb2510905220442n4a1c087nba2ab54a2fba360c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: kay.sievers@vrfy.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59814
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755402AbZEZJa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 05:30:56 -0400
In-Reply-To: <ac3eb2510905220442n4a1c087nba2ab54a2fba360c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kay Sievers <kay.sievers@vrfy.org>
Date: Fri, 22 May 2009 13:42:42 +0200

> just a quick check, to make sure we are prepared when 2.6.31 opens.
> Any updates regarding the BUS_ID_SIZE conversion?

I have a nearly completed patch and will make sure it gets into
2.6.31
