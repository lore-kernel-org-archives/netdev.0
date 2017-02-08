From: Igor Pylypiv <igor.pylypiv@gmail.com>
Subject: [PATCH] net: fix description of skb_find_text() according to removed functionality
Date: Tue, 7 Feb 2017 23:13:12 -0800
Message-ID: <CAPt+ddWT3g6qokWaHmsjYwuTQ-xMTa4qxLm6DLtyD6ngosc4PA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:36217 "EHLO
        mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752739AbdBHHNN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 02:13:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am not planning to to add a new user of this functions.
Use of skb_find_text() was a part of my Linux study and its
description informed me that I can use textsearch_next()
which I cannot. Just want to fix this.

On Tue, Feb 7, 2017 at 7:02 PM, David Miller <davem@davemloft.net> wrote:
>
> How about you make edits to this interface when you add an in-tree
> user as we mentioned in our responses to your previous patch?
>
> Thank you.
