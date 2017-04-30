From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v1 1/3] bnx2x: Replace custom scnprintf()
Date: Sun, 30 Apr 2017 15:58:18 +0300
Message-ID: <CAHp75VcitfXWzUsUDthAXp97yjQQnEGND7eqSH-AFRVjH6pYDg@mail.gmail.com>
References: <20170427133701.72701-1-andriy.shevchenko@linux.intel.com> <BLUPR0701MB2004B5244F758FC95EE1B5E88D150@BLUPR0701MB2004.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        "David S . Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Elior, Ariel" <Ariel.Elior@cavium.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:36247 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S969875AbdD3M6U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 08:58:20 -0400
Received: by mail-qt0-f195.google.com with SMTP id t52so13883876qtb.3
        for <netdev@vger.kernel.org>; Sun, 30 Apr 2017 05:58:19 -0700 (PDT)
In-Reply-To: <BLUPR0701MB2004B5244F758FC95EE1B5E88D150@BLUPR0701MB2004.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 30, 2017 at 11:16 AM, Mintz, Yuval <Yuval.Mintz@cavium.com> wrote:
>> From: Andy Shevchenko <andy.shevchenko@gmail.com>
>>
>> Use scnprintf() when printing version instead of custom open coded variants.
>>
>> Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
>
> Hi Andy this seems correct.
> Was there a cover-letter for your series? I've failed to find it.

There was none since patches are quite straight forward.

> [I was mostly interested in your motivation for this kind of cleanup]

Second and third are just consequences of first one.
First one I cooked about 3 years ago after recurrent kernel checking
for code duplication (hex_to_bin() and alike).
Just now I formed as a patch and compile checked it.

> Anyway, thanks.
> Acked-by: Yuval Mintz <Yuval.Mintz@cavium.com>

Thanks.

-- 
With Best Regards,
Andy Shevchenko
