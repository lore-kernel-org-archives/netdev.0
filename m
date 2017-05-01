From: carl h <heyen2000@gmail.com>
Subject: Re: How does vlan driver pass vlan info to the h/w ethernet driver
Date: Mon, 1 May 2017 15:35:12 -0400
Message-ID: <CABM+yxkVS71ksdcnxpTph5Va8=cPA=Cv95tXXOJ=a2vuAGt5_Q@mail.gmail.com>
References: <CABM+yxkiOpOs5b5MM6MD4woz5R2-4_gf=t=8THXb3p=wuwTtXg@mail.gmail.com>
 <20170501143703.GA1285@lunn.ch> <CABM+yxmdJD2k1kA+fY9Yva24oB8BuDDhS-FQdY2EJM1ghf6xWw@mail.gmail.com>
 <20170501.105736.157375316602250235.davem@davemloft.net> <CABM+yxnbLPjoq4E2Z3d2Jc5qUvN_TWUb6rQpjDWCTs=9j0ce3A@mail.gmail.com>
 <20170501192957.GA18265@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:33749 "EHLO
        mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750741AbdEATfO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 15:35:14 -0400
Received: by mail-lf0-f41.google.com with SMTP id 88so64568708lfr.0
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 12:35:13 -0700 (PDT)
In-Reply-To: <20170501192957.GA18265@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was afraid you were going to say that.

Thanks anyways Andrew.

On Mon, May 1, 2017 at 3:29 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Mon, May 01, 2017 at 02:26:52PM -0400, carl h wrote:
>> It appears that the switchdev driver model was introduced after 2.6.39
>> which is the
>> kernel version that I'm using unfortunately.
>
> We cannot help you much is you are using an ancient kernel. Please
> upgrade.
>
>         Andrew
