From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] net/flow_dissector: add support for
 dissection of misc ip header fields
Date: Tue, 30 May 2017 12:18:00 -0400 (EDT)
Message-ID: <20170530.121800.676375959648055594.davem@davemloft.net>
References: <CALx6S35LoybyU-NN8RTk4YMOmuOZTkJeZ6GVBnWbX6rtd2uM6Q@mail.gmail.com>
        <20170530131029.GD1838@nanopsycho>
        <CALx6S35Tkxc=PkdvpQWWWKgdBAOP5nmhCh1bP8LH9ochgG4ubQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, gerlitz.or@gmail.com, ogerlitz@mellanox.com,
        netdev@vger.kernel.org, saeedm@mellanox.com, roid@mellanox.com,
        paulb@mellanox.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52838 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750733AbdE3QSC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 12:18:02 -0400
In-Reply-To: <CALx6S35Tkxc=PkdvpQWWWKgdBAOP5nmhCh1bP8LH9ochgG4ubQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 30 May 2017 09:06:11 -0700

> The commit log does not mention cls_flower. There are no test results
> given for the impact of the patch. There is no description why tos and
> ttl are being added as opposed to id, flags, or IP options for that
> matter.

The top level merge commit explains everything, and since the patches
are grouped together logically, even if you just look at the merge
commit in the GIT tree, it is mentioned.

This has been going on for so long, it's kinda unreasonable for you to
start complaining now.

Thanks.
