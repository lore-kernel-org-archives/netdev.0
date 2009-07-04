From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] arp announce, arp_proxy and windows ip conflict verification
Date: Sat, 04 Jul 2009 16:47:31 -0700
Message-ID: <m17hyo57u4.fsf@fess.ebiederm.org>
References: <200907030246.18054.denys@visp.net.lb>
	<200907041803.25436.denys@visp.net.lb>
	<m13a9c6rhv.fsf@fess.ebiederm.org>
	<200907050100.08148.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:50643 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752704AbZGDXrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jul 2009 19:47:32 -0400
In-Reply-To: <200907050100.08148.denys@visp.net.lb> (Denys Fedoryschenko's message of "Sun\, 5 Jul 2009 01\:00\:08 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryschenko <denys@visp.net.lb> writes:

> On Sunday 05 July 2009 00:57:32 Eric W. Biederman wrote:
>>
>> How can that possibly be a correct network configuration?
>>
>> Eric
> It is a problem to have different networks, who doesn't communicate one with 
> each other, in same ethernet segment?
>
> Does it violate anything?

The point of the internet protocol is communications between networks.

Setting up a router to route traffic in and off of a network and not
telling it about one of the networks on your ethernet segment is
at the least very peculiar.

Eric







