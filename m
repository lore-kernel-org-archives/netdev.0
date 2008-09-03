From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [RESEND] [RFC PATCH] bonding: Do not tx-balance some IPv6 packets on ALB/TLB bonds
Date: Wed, 03 Sep 2008 07:29:49 -0700
Message-ID: <22734.1220452189@death.nxdomain.ibm.com>
References: <48B6FEC1.7090508@hp.com> <20080829.140806.130290207.davem@davemloft.net> <48BE9AED.5070306@pobox.com>
Cc: David Miller <davem@davemloft.net>, vladislav.yasevich@hp.com,
	netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:55623 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752504AbYICO37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 10:29:59 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m83EMdsB005854
	for <netdev@vger.kernel.org>; Wed, 3 Sep 2008 10:22:39 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m83ETtMb163414
	for <netdev@vger.kernel.org>; Wed, 3 Sep 2008 08:29:55 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m83ETsNp024858
	for <netdev@vger.kernel.org>; Wed, 3 Sep 2008 08:29:55 -0600
In-reply-to: <48BE9AED.5070306@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik <jgarzik@pobox.com> wrote:

>David Miller wrote:
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
>For 2.6.27-rc, I presume?

	Ok with me.  I haven't tested this yet (just got back from
vacation), but the description sounds reasonable.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
