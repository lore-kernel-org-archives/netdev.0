From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net v2] flow_dissector: Check skb for VLAN only if skb specified.
Date: Tue, 18 Oct 2016 16:59:31 +0300
Message-ID: <CAJ3xEMiR3EODEV5aQ9cQG=7YZtVfFkbpHn79_j+s8H7XQ5F0rA@mail.gmail.com>
References: <1476736212-21238-1-git-send-email-e@erig.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Eric Garver <e@erig.me>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:34744 "EHLO
        mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932339AbcJRN7d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 09:59:33 -0400
Received: by mail-oi0-f44.google.com with SMTP id t73so251151567oie.1
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 06:59:32 -0700 (PDT)
In-Reply-To: <1476736212-21238-1-git-send-email-e@erig.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 17, 2016 at 11:30 PM, Eric Garver <e@erig.me> wrote:
> Fixes a panic when calling eth_get_headlen(). Noticed on i40e driver.
>
> Fixes: d5709f7ab776 ("flow_dissector: For stripped vlan, get vlan info from skb->vlan_tci")
> Signed-off-by: Eric Garver <e@erig.me>

Dave,

Hadar is OOO and I have asked Amir to look on the fix, will appreciate
if we can have 24 hours to respond

Or.
