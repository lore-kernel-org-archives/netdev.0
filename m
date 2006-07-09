From: Jamal Hadi Salim <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Sun, 09 Jul 2006 09:17:51 -0400
Message-ID: <1152451071.5124.51.camel@jzny2>
References: <20060630.133348.68039806.davem@davemloft.net>
	 <1151700884.5270.278.camel@jzny2> <20060630211043.GO14627@postel.suug.ch>
	 <1151703097.5270.307.camel@jzny2> <20060630234512.GR14627@postel.suug.ch>
	 <1151722785.5093.51.camel@jzny2> <20060701112833.GS14627@postel.suug.ch>
	 <1151760901.5093.141.camel@jzny2> <20060708105451.GG14627@postel.suug.ch>
	 <1152368076.5272.39.camel@jzny2>  <20060708234602.GH14627@postel.suug.ch>
	 <1152449536.5124.31.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:29416 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1030491AbWGINRx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jul 2006 09:17:53 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FzZAZ-0001vm-2m
	for netdev@vger.kernel.org; Sun, 09 Jul 2006 09:17:55 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <1152449536.5124.31.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-09-07 at 08:52 -0400, Jamal Hadi Salim wrote:

Ok, didnt complete my thought there ..

> I dont like it, like i said, because it adds one more check
> in the first path. I was contemplating at some point even not doing the 


".. not doing the " check for device up and just shove the packet at it.

cheers,
jamal

PS:-  warning on response still applies.

