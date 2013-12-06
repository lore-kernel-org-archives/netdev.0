From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] net: of_mdio: parse "max-speed" property to set
 PHY supported features
Date: Thu, 05 Dec 2013 19:47:43 -0500 (EST)
Message-ID: <20131205.194743.1170844620568623022.davem@davemloft.net>
References: <1386283936-26104-6-git-send-email-florian@openwrt.org>
	<52A11F00.1070603@cogentembedded.com>
	<CAGVrzcYeRi=j3PkRbtNXwYFGOr9m7Yco0jORdp76i+DcRNpMFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	grant.likely@linaro.org, devicetree@vger.kernel.org,
	abrodkin@synopsys.com, rob.herring@calxeda.com,
	mark.rutland@arm.com, sebastian.hesselbarth@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60026 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752426Ab3LFArp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 19:47:45 -0500
In-Reply-To: <CAGVrzcYeRi=j3PkRbtNXwYFGOr9m7Yco0jORdp76i+DcRNpMFA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 5 Dec 2013 15:53:41 -0800

> 2013/12/5 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
>>>
>>> +       /* Set phydev->supported based on the "max-speed" property
>>> +        * if present */
>>
>>
>>    Preferred multi-line comment style is this:
>>
>> /*
>>  * bla
>>  * bla
>>  */
> 
> All other comments in this file are:
> 
> /* bla
>  * bla
>  */
> 
> which is why I used the same style.

And this is the preferred format for networking, as documented in
Documentation/networking/netdev-FAQ.txt
