From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] skbuff: align sk_buff::cb to 64 bit
Date: Fri, 12 Feb 2010 12:13:06 -0800 (PST)
Message-ID: <20100212.121306.225788982.davem@davemloft.net>
References: <1264835220.2919.10.camel@edumazet-laptop>
	<4B671CEB.5080505@caviumnetworks.com>
	<4B671F79.8090808@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ddaney@caviumnetworks.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, buytenh@wantstofly.org
To: nbd@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58464
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755960Ab0BLUMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 15:12:52 -0500
In-Reply-To: <4B671F79.8090808@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Fietkau <nbd@openwrt.org>
Date: Mon, 01 Feb 2010 19:37:45 +0100

> On 2010-02-01 7:26 PM, David Daney wrote:
>> Then perhaps add __aligned(8) to the entire structure instead of just 
>> this field.
> Makes sense, I'll send a patch for that.

Did that patch ever materialize? :-)
