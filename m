From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH 1/3] ipv4: initialize fib_trie prior to
 register_netdev_notifier call.
Date: Thu, 20 Jul 2017 10:20:06 -0700
Message-ID: <CAF2d9jjWUAffQ9MEc4E1uYTFR1=6EzhABffbTYSDdBwtimsVZQ@mail.gmail.com>
References: <20170719224133.34666-1-mahesh@bandewar.net> <20170719.225136.647816601138954194.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: mahesh@bandewar.net, ebiederm@xmission.com,
        Eric Dumazet <edumazet@google.com>,
        linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:38315 "EHLO
        mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935106AbdGTRU1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 13:20:27 -0400
Received: by mail-io0-f182.google.com with SMTP id g13so14037716ioj.5
        for <netdev@vger.kernel.org>; Thu, 20 Jul 2017 10:20:27 -0700 (PDT)
In-Reply-To: <20170719.225136.647816601138954194.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 19, 2017 at 10:51 PM, David Miller <davem@davemloft.net> wrote:
>
> Where are patches #2 and #3?
Oops, my bad! I wanted to detach this from the series and send it
independently but forgot to update the header in process. Do you want
me to send it again with just the header change [PATCH 1/3] to [PATCH
next]?
