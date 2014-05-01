From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: HHF support in iproute2?
Date: Thu, 01 May 2014 08:23:59 -0700
Message-ID: <5362670F.2080400@gmail.com>
References: <4420ec641916f42ac8bb9becc634a8cf@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>,
	netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:53531 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833AbaEAPYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2014 11:24:19 -0400
Received: by mail-ob0-f180.google.com with SMTP id va2so1077534obc.39
        for <netdev@vger.kernel.org>; Thu, 01 May 2014 08:24:18 -0700 (PDT)
In-Reply-To: <4420ec641916f42ac8bb9becc634a8cf@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/2014 09:11 PM, Denys Fedoryshchenko wrote:
> Hi
>
> I just tried recently last iproute2 (git and release) and noticed in
> iproute-3.14.0 it is still missing HHF support, while i see it is
> accepted in git
> (http://marc.info/?l=linux-netdev&m=138933793006411&w=2)
> Is there any problem with this scheduling discipline?
>
> Thanks!

Hi Stephen,

I can't seem to find this patch either. I checked the repository
at git.kernel.org and it looks like q_hhf.c is missing.

Was this intentional? Or am I just missing something. I have the
patch applied locally and it seems to work OK.

Thanks,
John

-- 
John Fastabend         Intel Corporation
