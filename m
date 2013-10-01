From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [PATCH net-next] include/linux/skbuff.h: move CONFIG_XFRM check
 inside the skb_sec_path()
Date: Tue, 1 Oct 2013 10:51:23 +0400
Message-ID: <CAOJe8K2QD7M=DFeoS3Fa61c9nTbvBVS4Ysvokp_6b-rfDRYt=A@mail.gmail.com>
References: <1380463645-4633-1-git-send-email-kda@linux-powerpc.org>
	<20130930.222557.2127518665116094800.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:64943 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871Ab3JAGvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 02:51:23 -0400
Received: by mail-ob0-f173.google.com with SMTP id vb8so5547549obc.4
        for <netdev@vger.kernel.org>; Mon, 30 Sep 2013 23:51:23 -0700 (PDT)
In-Reply-To: <20130930.222557.2127518665116094800.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No problem, I'll respin.

Thanks!

On 10/1/13, David Miller <davem@davemloft.net> wrote:
> From: Denis Kirjanov <kda@linux-powerpc.org>
> Date: Sun, 29 Sep 2013 18:07:25 +0400
>
>> And thus we have only one function definition
>>
>> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
>
> This does not apply cleanly to the current net-next tree.
>
