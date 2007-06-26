From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFD] L2 Network namespace infrastructure
Date: Tue, 26 Jun 2007 09:32:15 -0600
Message-ID: <m11wfyu3y8.fsf@ebiederm.dsl.xmission.com>
References: <m1ir9e8i2r.fsf@ebiederm.dsl.xmission.com>
	<20070623.224511.00323567.davem@davemloft.net>
	<m1zm2p7bld.fsf@ebiederm.dsl.xmission.com>
	<20070624.193956.128596032.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org, hadi@cyberus.ca,
	shemminger@linux-foundation.org, greearb@candelatech.com,
	jeff@garzik.org, yoshfuji@linux-ipv6.org,
	containers@lists.osdl.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:60346 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755842AbXFZPdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2007 11:33:47 -0400
In-Reply-To: <20070624.193956.128596032.davem@davemloft.net> (David Miller's
	message of "Sun, 24 Jun 2007 19:39:56 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Sun, 24 Jun 2007 06:58:54 -0600
>
>> I am convinced I can keep network namespaces something that is so
>> trivial and obvious to get right you won't have to pay attention
>> to them.
>
> Ok then, I'll hold you to this when you post the rest of your
> implementation :-)

Sounds fair to me.  I definitely don't want a network stack
that is noticeably harder to maintain.

Eric
