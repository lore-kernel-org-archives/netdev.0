From: Dustin Schumm <shodid@gmail.com>
Subject: Re: Reoccuring kern.log events after running xl2tp with ethernet
 adapter Realtek 8111E
Date: Wed, 6 Jun 2012 15:04:58 -0400
Message-ID: <CANcVnzjKCn00kF8NG+ZLLrzGCs_jx7WYPKyM7uwrxJ=kVLiQ4Q@mail.gmail.com>
References: <CANcVnzi2mXKXZLcaAt9rJ9OOdK_2=V8JV9uebVeBcsDu6j+DhQ@mail.gmail.com>
	<CANcVnzivnQrhSderZ+b5yoy+F1OiO7Ajv7WeijqzQKyAkYRqug@mail.gmail.com>
	<20120605153753.GA12514@electric-eye.fr.zoreil.com>
	<CANcVnzj-DUD8x9jcj3awyWkZjH9x5PMf3fAFtR_osPNAU9adgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:48222 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757872Ab2FFTFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 15:05:00 -0400
Received: by weyu7 with SMTP id u7so4547677wey.19
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2012 12:04:58 -0700 (PDT)
In-Reply-To: <CANcVnzj-DUD8x9jcj3awyWkZjH9x5PMf3fAFtR_osPNAU9adgA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 5, 2012 at 11:59 AM, Dustin Schumm <shodid@gmail.com> wrote:
> On Tue, Jun 5, 2012 at 11:37 AM, Francois Romieu <romieu@fr.zoreil.com> wrote:
>>
>> This is with an usual 1500 bytes MTU and without TSO (see 'ethtool -k ethX'),
>> right ?
>>
>> --
>> Ueimor
>
> Yes,
>
> MTU:1500
> tcp-segmentation-offload: off

Do you see any indication if this is a problem with the mainline
kernel, distro kernel, driver, or otherwise? It's not definitive, been
I've been good using kernels 2.6.x and getting errors on everything
3.x I have tried. I am looking for some direction to pursue. Thanks.

-Dustin
