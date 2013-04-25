From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] 3c509.c: call SET_NETDEV_DEV for all device types (ISA/ISAPnP/EISA)
Date: Fri, 26 Apr 2013 02:10:26 +0400
Message-ID: <5179A9D2.7080508@cogentembedded.com>
References: <1366921743-6440-1-git-send-email-tedheadster@gmail.com> <51799A39.6070002@cogentembedded.com> <51799EFF.10003@cogentembedded.com> <20130425143038.5adb5078e7e6a69a10c43e69@linux-foundation.org> <5179A215.9070101@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matthew Whitehead <tedheadster@gmail.com>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:56768 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932999Ab3DYWLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 18:11:44 -0400
Received: by mail-lb0-f172.google.com with SMTP id d10so362759lbj.31
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 15:11:42 -0700 (PDT)
In-Reply-To: <5179A215.9070101@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 26-04-2013 1:37, Sergei Shtylyov wrote:

>>>>      BTW, it seems that after almost 7 years I seem to have found a tester
>>>> for
>>>> my patch which lingered all this time in the Andrew Morton's tree! You've
>>>> said
>>>> you have EISA boards, how about testing my patch? Now if I could find Andrew
>>>> Morton's tree... Andrew?

>>>      Found it at last at ozlabs.org but it turned out that Andrew has dropped
>>> the patch without notifying me. :-(

>> nah, you were asleep ;)

>    Nope, I was actively protesting, although I don't have my messages now,
> have only found yours.

>> Message-Id: <200906101955.n5AJtMg7008475@imap1.linux-foundation.org>
>> Subject: [obsolete] 3x59x-fix-pci-resource-management.patch removed from -mm
>> tree
>> To: sshtylyov@ru.mvista.com, mm-commits@vger.kernel.org
>> From: akpm@linux-foundation.org
>> Date:   Wed, 10 Jun 2009 12:55:21 -0700

    In fact, you've readded the patch top you tree the next day. Then the 
discussion continued in August 2009 until DaveM told you to repost this once 
it had at least CardBus testing...

WBR, Sergei
