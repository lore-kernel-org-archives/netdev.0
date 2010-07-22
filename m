From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Another oops + repost
Date: Thu, 22 Jul 2010 09:43:10 -0700
Message-ID: <m1zkxjwjq9.fsf@fess.ebiederm.org>
References: <AANLkTin_KDKEejs1ld-qv5jOyuALysjZ8NLC2-786htJ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Ben Hutchings <ben@decadent.org.uk>, 577640@bugs.debian.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Mathieu Lacage <mathieu.lacage@sophia.inria.fr>,
	Daniel Lezcano <daniel.lezcano@free.fr>
To: =?utf-8?Q?Mart=C3=ADn?= Ferrari <martin.ferrari@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:42897 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005Ab0GVQnU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 12:43:20 -0400
In-Reply-To: <AANLkTin_KDKEejs1ld-qv5jOyuALysjZ8NLC2-786htJ@mail.gmail.com>
 (=?utf-8?Q?=22Mart=C3=ADn?= Ferrari"'s message of "Thu\, 22 Jul 2010
 14\:24\:39 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mart=C3=ADn Ferrari <martin.ferrari@gmail.com> writes:

> Hi again,
>
> First of all, I would like to know if anybody was able to fix this
> problem  that got kinda lost in the thread:

I can't reproduce this on 2.6.35-rc1+

Can you please test a 2.6.35-rc version?  If you can still reproduce
it there can you send me your .config?  Otherwise I expect my last
round of changes to sysfs fixed whatever was the underlying problem.

Thanks,
Eric
