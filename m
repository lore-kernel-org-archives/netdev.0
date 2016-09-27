From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: kernel BUG at net/unix/garbage.c:149!"
Date: Tue, 27 Sep 2016 16:43:18 +0200
Message-ID: <1474987398.3056249.738530265.402E1E43@webmail.messagingengine.com>
References: <57BDAE06.1040400@kyup.com>
 <9dde3145-9128-ffef-1b84-e3bd429dd4e8@stressinduktion.org>
 <CAOssrKddiaWQX+v7FZTJg9mwyhxHJCDQQMUJVwP17-z1ATrKWA@mail.gmail.com>
 <CAOssrKedUEAcZThhd2FB9UPzhr+5ErLjB=3+1z1XdnFeP6wvmg@mail.gmail.com>
 <CAOssrKcfncAYsQWkfLGFgoOxAQJVT2hYVWdBA6Cw7hhO8RJ_wQ@mail.gmail.com>
 <57EA7F3B.3030801@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Miklos Szeredi <mszeredi@redhat.com>,
        "Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
        netdev@vger.kernel.org
To: Nikolay Borisov <kernel@kyup.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:58831 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933854AbcI0OnY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 10:43:24 -0400
In-Reply-To: <57EA7F3B.3030801@kyup.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 27, 2016, at 16:16, Nikolay Borisov wrote:
> Dave,
> 
> What's the status of https://patchwork.ozlabs.org/patch/664062/ , is
> this going to be picked up ?

Not sure if we actually fix a bug with this. Miklos could you maybe
enhance the changelog then?

Thanks,
Hannes
