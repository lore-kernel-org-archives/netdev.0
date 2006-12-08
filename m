From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Devel] Re: Network virtualization/isolation
Date: Fri, 08 Dec 2006 12:57:49 -0700
Message-ID: <m164cm2m9u.fsf@ebiederm.dsl.xmission.com>
References: <453F8800.9070603@fr.ibm.com> <1165239894.3664.61.camel@localhost>
	<m1k617u10x.fsf@ebiederm.dsl.xmission.com>
	<200612041900.42768.dim@openvz.org>
	<m1odqj8uyt.fsf@ebiederm.dsl.xmission.com> <4576AF68.2070604@sw.ru>
	<20061206183036.GA16927@MAIL.13thfloor.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kirill Korotaev <dev@sw.ru>,
	Linux Containers <containers@lists.osdl.org>,
	Dmitry Mishin <dim@openvz.org>, netdev@vger.kernel.org,
	hadi@cyberus.ca, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:34596 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1426174AbWLHT70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Dec 2006 14:59:26 -0500
To: Herbert Poetzl <herbert@13thfloor.at>
In-Reply-To: <20061206183036.GA16927@MAIL.13thfloor.at> (Herbert Poetzl's
	message of "Wed, 6 Dec 2006 19:30:36 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Poetzl <herbert@13thfloor.at> writes:

>> But, ok, it is not the real point to argue so much imho and waste our
>> time instead of doing things.
>
> well, IMHO better talk (and think) first, then implement
> something ... not the other way round, and then start
> fixing up the mess ...

Well we need a bit of both.

This is thankfully not exported to user space, so as long as our
implementation is correct it doesn't much matter.

I do agree with the point that context may make sense.  I have
yet to be convinced though.

Eric
