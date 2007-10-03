From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH 5/7] CAN: Add virtual CAN netdevice driver
Date: Wed, 03 Oct 2007 09:06:52 +0200
Message-ID: <47033F8C.6060706@hartkopp.net>
References: <20071002142016.GE7881@ghostprotocols.net>	<4702B1FD.70102@hartkopp.net>	<20071002214325.GB3576@ghostprotocols.net> <20071002.145034.15615464.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: urs@isnogud.escape.de, netdev@vger.kernel.org, kaber@trash.net,
	tglx@linutronix.de, yoshfuji@linux-ipv6.org, ebiederm@xmission.com,
	oliver.hartkopp@volkswagen.de, urs.thuermann@volkswagen.de
To: David Miller <davem@davemloft.net>, acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:44544 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752405AbXJCHHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 03:07:14 -0400
In-Reply-To: <20071002.145034.15615464.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
> Date: Tue, 2 Oct 2007 18:43:25 -0300
>
>   
>> I think that helping ctags to find the definition for the debug variable
>> to see, for instance, if it is a bitmask or a boolean without having to
>> chose from tons of 'debug' variables is a good thing.
>>     
>
> I completely agree.
>   

OK. No problem if it's helpful. We'll change debug to vcan_debug.

Thanks.

Oliver
