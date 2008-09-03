From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RESEND] [RFC PATCH] bonding: Do not tx-balance some IPv6 packets
 on ALB/TLB bonds
Date: Wed, 03 Sep 2008 10:10:53 -0400
Message-ID: <48BE9AED.5070306@pobox.com>
References: <48B6FEC1.7090508@hp.com> <20080829.140806.130290207.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, fubar@us.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49383 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753113AbYICOK6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 10:10:58 -0400
In-Reply-To: <20080829.140806.130290207.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Thu, 28 Aug 2008 15:38:41 -0400
> 
>> It's been more then a month and still no replies.  Is this just
>> not interesting, or did this get lost in the shuffle...
>>
>> Please take a look.  This patch makes ALB/TLB modes work much more
>> reliably with IPv6.
> 
> Jeff, or someone, please be sure to pick this up.

For 2.6.27-rc, I presume?


