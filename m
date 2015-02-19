From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: bpf: Enable BPF JIT on ppc32
Date: Fri, 20 Feb 2015 01:07:50 +0400
Message-ID: <CAOJe8K0awkwdYNZr5GdRJFQLCJ0F1GOF730Q3UwT7KBJw0c7Uw@mail.gmail.com>
References: <1424156683-2682-1-git-send-email-kda@linux-powerpc.org>
	<20150219.155613.1219259214030608341.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f52.google.com ([209.85.213.52]:33679 "EHLO
	mail-yh0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752595AbbBSVHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 16:07:51 -0500
Received: by yhl29 with SMTP id 29so1477996yhl.0
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2015 13:07:50 -0800 (PST)
In-Reply-To: <20150219.155613.1219259214030608341.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/19/15, David Miller <davem@davemloft.net> wrote:
> From: Denis Kirjanov <kda@linux-powerpc.org>
> Date: Tue, 17 Feb 2015 10:04:37 +0300
>
>> This patch series enables BPF JIT on ppc32. There are relatevily
>> few chnages in the code to make it work.
>>
>> All test_bpf tests passed both on 7447a and P2041-based machines.
>>
>> Changelog:
>> v1 - > v2: Reordered Kconfig patch in the series
>
> Who plans to take this series?  A PowerPC maintainer?
>
> If not, should I take it?
>

I think that it should go through your tree...
