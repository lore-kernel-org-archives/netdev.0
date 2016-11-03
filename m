From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] ipv4: allow local fragmentation in
 ip_finish_output_gso()
Date: Thu, 03 Nov 2016 16:56:36 -0400 (EDT)
Message-ID: <20161103.165636.214378650144831119.davem@davemloft.net>
References: <1478118977-19608-1-git-send-email-lrichard@redhat.com>
        <20161103.161244.1518109748163260273.davem@davemloft.net>
        <20161103224052.5e066584@halley>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lrichard@redhat.com, netdev@vger.kernel.org, fw@strlen.de,
        jtluka@redhat.com, hannes@stressinduktion.org
To: shmulik.ladkani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43482 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750764AbcKCU4i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 16:56:38 -0400
In-Reply-To: <20161103224052.5e066584@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Date: Thu, 3 Nov 2016 22:40:52 +0200

> On Thu, 03 Nov 2016 16:12:44 -0400 (EDT) David Miller <davem@davemloft.net> wrote:
>> Applied and queued up for -stable.
> 
> Dave, my response lagged your "Applied" by few minutes ;)
> 
> This seems to deserve some more thought to make sure nothing got broken,
> as expressed last in https://patchwork.ozlabs.org/patch/690594/

Feel free to send a followup or a revert if necessary.
