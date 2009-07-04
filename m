From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] arp announce, arp_proxy and windows ip conflict verification
Date: Sat, 04 Jul 2009 14:57:32 -0700
Message-ID: <m13a9c6rhv.fsf@fess.ebiederm.org>
References: <200907030246.18054.denys@visp.net.lb>
	<200907041055.24516.denys@visp.net.lb>
	<m1fxdc8pcl.fsf@fess.ebiederm.org>
	<200907041803.25436.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:36421 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752276AbZGDV5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jul 2009 17:57:33 -0400
In-Reply-To: <200907041803.25436.denys@visp.net.lb> (Denys Fedoryschenko's message of "Sat\, 4 Jul 2009 18\:03\:25 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryschenko <denys@visp.net.lb> writes:

> On Saturday 04 July 2009 18:00:58 Eric W. Biederman wrote:
>>
>> Problems occur when you have machines with ip addresses that you don't
>> have routes to.  How do machines with addresses without routes to them
>> get packets from machines in other subnets.
>>
>> Eric
> They are not supposed to communicate then with this Linux host.
> But Linux poisoning them by ARP replies.

How can that possibly be a correct network configuration?

Eric
