From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next-2.6]: xfrm: Introduce
 LINUX_MIB_XFRMFWDHDRERROR
Date: Thu, 18 Feb 2010 15:44:20 -0800 (PST)
Message-ID: <20100218.154420.131884035.davem@davemloft.net>
References: <1266406852.3799.7.camel@bigi>
	<20100217.134946.106752388.davem@davemloft.net>
	<1266500107.17794.167.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nakam@linux-ipv6.org, kaber@trash.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37489
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751687Ab0BRXoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 18:44:04 -0500
In-Reply-To: <1266500107.17794.167.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Thu, 18 Feb 2010 08:35:07 -0500

> On Wed, 2010-02-17 at 13:49 -0800, David Miller wrote:
> 
>> This should be fine, the tools just parse the lines individually
>> as "string integer" pairs.
>> 
>> If you want to be super anal, add the new counter to the end of
>> the array.
> 
> Ok, thanks - here is the updated patch.

Applied, thanks Jamal.
