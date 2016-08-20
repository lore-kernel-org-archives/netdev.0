From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH v1 1/1] l2tp: Use existing macros instead of literal number
Date: Sat, 20 Aug 2016 14:24:36 +0800
Message-ID: <CA+6hz4rWg6LW3=rLJwosFmAHDO70CnBzkPq3NBy0-bnuoQhNjA@mail.gmail.com>
References: <1471600526-22584-1-git-send-email-fgao@ikuai8.com> <20160819182854.wdgnz77h2pins2c5@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Gao Feng <fgao@ikuai8.com>, jchapman@katalix.com,
        "David S. Miller" <davem@davemloft.net>,
        Philp Prindeville <philipp@redfish-solutions.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f195.google.com ([209.85.217.195]:34631 "EHLO
        mail-ua0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751164AbcHTGYi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2016 02:24:38 -0400
Received: by mail-ua0-f195.google.com with SMTP id d97so7018648uad.1
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 23:24:38 -0700 (PDT)
In-Reply-To: <20160819182854.wdgnz77h2pins2c5@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, I forget to modify the title.
I will sent another update.

On Sat, Aug 20, 2016 at 2:28 AM, Guillaume Nault <g.nault@alphalink.fr> wrote:
> On Fri, Aug 19, 2016 at 05:55:26PM +0800, fgao@ikuai8.com wrote:
>> From: Gao Feng <fgao@ikuai8.com>
>>
>> 1. Use PPP_ALLSTATIONS/PPP_UI instead of literal 0xff/0x03;
>> 2. Use one static const global fixed_ppphdr instead of two same
>> static variable ppph in two different functions;
>> 3. Use SEND_SHUTDOWN instead of literal 2;
>>
>> Signed-off-by: Gao Feng <fgao@ikuai8.com>
>> ---
>>  v1: Initial patch
>>
> v1 again?
>
> BTW, no need to number your patch for a single patch series.
> But you have to tell which tree is the series for.
>
> So instead of [PATCH v1 1/1], you should send [PATCH v2 net-next].
