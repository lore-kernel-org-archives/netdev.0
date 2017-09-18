From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Documentation: networking: fix ASCII art in
 switchdev.txt
Date: Mon, 18 Sep 2017 16:39:18 -0700 (PDT)
Message-ID: <20170918.163918.1413944718199683496.davem@davemloft.net>
References: <984d9d24-b558-6308-3252-1c8ddd5eb7c8@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pavel@ucw.cz, andrew@lunn.ch,
        schwab@linux-m68k.org, jiri@resnulli.us, sfeldma@gmail.com
To: rdunlap@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58642 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750711AbdIRXjT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 19:39:19 -0400
In-Reply-To: <984d9d24-b558-6308-3252-1c8ddd5eb7c8@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>
Date: Sat, 16 Sep 2017 13:10:06 -0700

> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Fix ASCII art in Documentation/networking/switchdev.txt:
> 
> Change non-ASCII "spaces" to ASCII spaces.
> 
> Change 2 erroneous '+' characters in ASCII art to '-' (at the '*'
> characters below):
> 
> line 32:
>                      +--+----+----+----+-*--+----+---+  +-----+-----+
> line 41:
>                      +--------------+---*------------+
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>

Applied, thanks Randy.
