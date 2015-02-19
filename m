From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: bpf: Enable BPF JIT on ppc32
Date: Fri, 20 Feb 2015 01:35:59 +0400
Message-ID: <CAOJe8K1qWYOXRvHqV44JsEkOhXXKsCCN8fQ=wmy=3VHLSMpm0Q@mail.gmail.com>
References: <1424156683-2682-1-git-send-email-kda@linux-powerpc.org>
	<20150219.155613.1219259214030608341.davem@davemloft.net>
	<CAOJe8K0awkwdYNZr5GdRJFQLCJ0F1GOF730Q3UwT7KBJw0c7Uw@mail.gmail.com>
	<1424381177.22771.1.camel@ellerman.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: Michael Ellerman <mpe@ellerman.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:46055 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753141AbbBSVgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 16:36:00 -0500
Received: by mail-yk0-f177.google.com with SMTP id 20so5294003yks.8
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2015 13:35:59 -0800 (PST)
In-Reply-To: <1424381177.22771.1.camel@ellerman.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/20/15, Michael Ellerman <mpe@ellerman.id.au> wrote:
> On Fri, 2015-02-20 at 01:07 +0400, Denis Kirjanov wrote:
>> On 2/19/15, David Miller <davem@davemloft.net> wrote:
>> > From: Denis Kirjanov <kda@linux-powerpc.org>
>> > Date: Tue, 17 Feb 2015 10:04:37 +0300
>> >
>> >> This patch series enables BPF JIT on ppc32. There are relatevily
>> >> few chnages in the code to make it work.
>> >>
>> >> All test_bpf tests passed both on 7447a and P2041-based machines.
>> >>
>> >> Changelog:
>> >> v1 - > v2: Reordered Kconfig patch in the series
>> >
>> > Who plans to take this series?  A PowerPC maintainer?
>> >
>> > If not, should I take it?
>>
>> I think that it should go through your tree...
>
> I'm happy for Dave to take it.
>
> But did you test 64-bit as well?

Sure!

> cheers
>
>
>
