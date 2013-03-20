From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: [PATCH 1/2] genetlink: trigger BUG_ON if a group name is too long
Date: Wed, 20 Mar 2013 14:16:22 -0700
Message-ID: <CAE9FiQX+9NXfVO9P1ZELYjA+D35Tt7r0ngsGZfW9VaU1Q0WJvQ@mail.gmail.com>
References: <CAE9FiQURBR=iTbksUzb_i23g6N56Acg2J8bab9zr1UcwT5tWzA@mail.gmail.com>
	<20130320.170511.343122156621608721.davem@davemloft.net>
	<CAE9FiQXgv8EZGQ142NyV5D1M2+HKSaSoafNzdXY2SBO+iQjdGw@mail.gmail.com>
	<20130320.171305.1359445944793447383.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: rui.zhang@intel.com, yamato@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f181.google.com ([209.85.210.181]:48897 "EHLO
	mail-ia0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758Ab3CTVQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 17:16:23 -0400
Received: by mail-ia0-f181.google.com with SMTP id o25so1807517iad.26
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 14:16:22 -0700 (PDT)
In-Reply-To: <20130320.171305.1359445944793447383.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 20, 2013 at 2:13 PM, David Miller <davem@davemloft.net> wrote:
>>
>> [    6.047966] ------------[ cut here ]------------
>> [    6.048944] kernel BUG at net/netlink/genetlink.c:145!
>
> For the second time, we know about this bug.
>
> His second patch fixes the themal layer bug.
>
> But I told him to send it to the thermal maintainers so that they
> can integrate it.
>
> Why are you posting what we know already over and over?

so bisecting will be broken?
