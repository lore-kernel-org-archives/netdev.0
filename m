From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] IB/ipoib: Bound the net device to the ipoib_neigh structue
Date: Tue, 09 Oct 2007 18:18:52 -0700
Message-ID: <706.1191979132@death>
References: <11916151232222-git-send-email-fubar@us.ibm.com> <470C200D.4010705@pobox.com> <470C2343.1020800@garzik.org> <20071009.181246.41634534.davem@davemloft.net>
Cc: jeff@garzik.org, monis@voltaire.com, ogerlitz@voltaire.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:52596 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752204AbXJJBTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 21:19:03 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l9A0AI4e015972
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 20:10:18 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9A1Itt5434060
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 19:18:55 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9A1IsBh005893
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 19:18:55 -0600
In-reply-to: <20071009.181246.41634534.davem@davemloft.net> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:

>From: Jeff Garzik <jeff@garzik.org>
>Date: Tue, 09 Oct 2007 20:56:35 -0400
>
>> Jeff Garzik wrote:
>> > applied patches 1-9
>> > 
>> > the only thing that was a hiccup during submission is that your email 
>> > subject lines did not contain a notion of ordering "[PATCH 1/9] ...". 
>> > But other than that, the git-send-email went flawlessly.
>> 
>> unfortunately it does not seem to build flawlessly:
>
>Yeah it doesn't handle Stephen Hemmingers headerops change
>in net-2.6.24

	Gaah.  I'll sort it out and repost.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
