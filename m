From: Grant Grundler <grundler@chromium.org>
Subject: Re: [PATCH] asix: new device id
Date: Mon, 19 Dec 2011 13:34:24 -0800
Message-ID: <CANEJEGtiHZRzQgGnBDZnuGvuZOfXxwcDdB9XdxYgO1zY7O_GVw@mail.gmail.com>
References: <1324068562-3761-1-git-send-email-aurel@gnuage.org>
	<20111219.160059.783127741333326755.davem@davemloft.net>
	<CANEJEGswxaxgD9eet9uDZm6Ezf67ibG0XOTggSBONZ6M1KMErA@mail.gmail.com>
	<20111219.162516.1008359598690049381.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: aurel@gnuage.org, netdev@vger.kernel.org, allan@asix.com.tw,
	freddy@asix.com.tw
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:37182 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751974Ab1LSVeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 16:34:25 -0500
Received: by obcwo16 with SMTP id wo16so1960282obc.19
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2011 13:34:25 -0800 (PST)
In-Reply-To: <20111219.162516.1008359598690049381.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 19, 2011 at 1:25 PM, David Miller <davem@davemloft.net> wrote:
> From: Grant Grundler <grundler@google.com>
> Date: Mon, 19 Dec 2011 13:22:35 -0800
>
>> I'm really the wrong guy to ask though. I don't have the device
>> and I'm not associated with the mfg.
>
> Strongly disagree.
>
> When you make changes to a driver, in fact you've made the most
> recent 5 or 6, it's like "tag, you're it" :-)

Fair enough. :)   But I'm trying to change that. :) (Have ASIX to
participate in asix.c devel/support).


Acked-by: Grant Grundler <grundler@chromium.org>

The change is "harmless" in that it won't interfere with anything that
works today.

> Just so you understand why I am not going to ask random people who
> have never submitted a change to the driver whether a change makes
> sense or not.

Understood. But I have no clue what driver functionality *will* work
with the new device.
I guess this is the first step to finding out. :)

cheers,
grant
