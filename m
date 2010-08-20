From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/8] net_sched: cls_flow: use proto_ports_offset() to
 support AH message
Date: Thu, 19 Aug 2010 17:17:19 -0700 (PDT)
Message-ID: <20100819.171719.27791197.davem@davemloft.net>
References: <1282136070.23601.26.camel@bigi>
	<AANLkTin9Pm0oPpteYsZsPUEyAj9qMxrSL9k1GXNYeY9h@mail.gmail.com>
	<1282139589.23601.38.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49314
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752440Ab0HTARC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 20:17:02 -0400
In-Reply-To: <1282139589.23601.38.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Wed, 18 Aug 2010 09:53:09 -0400

> On Wed, 2010-08-18 at 21:18 +0800, Changli Gao wrote:
> 
>> I had gone through the code before submitting this code. But it isn't
>> easy to test if it breaks sth. 
> 
> That works well actually and it is the LinuxWay(tm);-> 
> 
>> Would you please give a case to test ?
> 
> Just conformance testing. Since you added new AH SPI behavior
> at least find some use case of what people normally use and make sure it
> isnt broken. But if youve looked at code sufficiently i think thats good
> enough.

I agree and I've applied his patch.
