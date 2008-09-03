From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [RESEND] [RFC PATCH] bonding: Do not tx-balance some IPv6 packets
 on ALB/TLB bonds
Date: Wed, 03 Sep 2008 10:21:33 -0400
Message-ID: <48BE9D6D.7080600@hp.com>
References: <48B6FEC1.7090508@hp.com> <20080829.140806.130290207.davem@davemloft.net> <48BE9AED.5070306@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, fubar@us.ibm.com,
	netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:33377 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753531AbYICOV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 10:21:56 -0400
In-Reply-To: <48BE9AED.5070306@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> David Miller wrote:
>> From: Vlad Yasevich <vladislav.yasevich@hp.com>
>> Date: Thu, 28 Aug 2008 15:38:41 -0400
>>
>>> It's been more then a month and still no replies.  Is this just
>>> not interesting, or did this get lost in the shuffle...
>>>
>>> Please take a look.  This patch makes ALB/TLB modes work much more
>>> reliably with IPv6.
>>
>> Jeff, or someone, please be sure to pick this up.
> 
> For 2.6.27-rc, I presume?
> 
> 

Fine by me.

Thanks
-vlad
