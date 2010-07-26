From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Another oops + repost
Date: Mon, 26 Jul 2010 02:45:46 -0700
Message-ID: <m1tynmtw39.fsf@fess.ebiederm.org>
References: <AANLkTin_KDKEejs1ld-qv5jOyuALysjZ8NLC2-786htJ@mail.gmail.com>
	<m1zkxjwjq9.fsf@fess.ebiederm.org>
	<AANLkTimC8q6_ZU60VX5SmXGqsD+RCpf4RaF3MLQptsG4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, 577640@bugs.debian.org
To: =?utf-8?Q?Mart=C3=ADn?= Ferrari <martin.ferrari@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:43678 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753835Ab0GZJpv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 05:45:51 -0400
In-Reply-To: <AANLkTimC8q6_ZU60VX5SmXGqsD+RCpf4RaF3MLQptsG4@mail.gmail.com>
 (=?utf-8?Q?=22Mart=C3=ADn?= Ferrari"'s message of "Mon\, 26 Jul 2010
 05\:21\:45 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mart=C3=ADn Ferrari <martin.ferrari@gmail.com> writes:

> Hi,
>
> On Thu, Jul 22, 2010 at 18:43, Eric W. Biederman <ebiederm@xmission.c=
om> wrote:
>
>>> First of all, I would like to know if anybody was able to fix this
>>> problem =C2=A0that got kinda lost in the thread:
>>
>> I can't reproduce this on 2.6.35-rc1+
>>
>> Can you please test a 2.6.35-rc version? =C2=A0If you can still repr=
oduce
>> it there can you send me your .config? =C2=A0Otherwise I expect my l=
ast
>> round of changes to sysfs fixed whatever was the underlying problem.
>
> I just download and compiled rc6, and all of these problems seem to b=
e
> solved. Thanks a lot!

Welcome.  I'm glad to hear there wasn't some weird corner case
that I had missed.

Eric
