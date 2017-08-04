From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] lwtunnel: replace EXPORT_SYMBOL with EXPORT_SYMBOL_GPL
Date: Fri, 4 Aug 2017 15:36:21 -0700
Message-ID: <CAJieiUi_y6zZXhfu-AWY=u+j20VQMzJ-45AWoaRHFQtiaX8ftg@mail.gmail.com>
References: <1501885417-18966-1-git-send-email-roopa@cumulusnetworks.com> <20170804222528.GD11696@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f178.google.com ([209.85.217.178]:38231 "EHLO
        mail-ua0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752001AbdHDWgW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 18:36:22 -0400
Received: by mail-ua0-f178.google.com with SMTP id w45so12798232uac.5
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 15:36:22 -0700 (PDT)
In-Reply-To: <20170804222528.GD11696@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 4, 2017 at 3:25 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Fri, Aug 04, 2017 at 03:23:37PM -0700, Roopa Prabhu wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> ---
>>  net/core/lwtunnel.c | 26 +++++++++++++-------------
>>  1 file changed, 13 insertions(+), 13 deletions(-)
>>
>> diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
>> index d9cb353..8693ff8 100644
>> --- a/net/core/lwtunnel.c
>> +++ b/net/core/lwtunnel.c
>> @@ -65,7 +65,7 @@ struct lwtunnel_state *lwtunnel_state_alloc(int encap_len)
>>
>>       return lws;
>>  }
>> -EXPORT_SYMBOL(lwtunnel_state_alloc);
>> +EXPORT_SYMBOL_GPL_GPL(lwtunnel_state_alloc);
>
> Hi Roopa
>
> GPL_GPL?
>

oops, i had fixed it but sent the wrong version. thx
