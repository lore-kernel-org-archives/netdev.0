From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: dev: deinit list in unregister_netdevice_many
Date: Tue, 26 Feb 2013 23:25:13 -0800
Message-ID: <1361949913.11403.22.camel@edumazet-glaptop>
References: <1361948391-4906-1-git-send-email-gaofeng@cn.fujitsu.com>
	 <1361949146.11403.21.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f54.google.com ([209.85.210.54]:59687 "EHLO
	mail-da0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818Ab3B0HZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 02:25:16 -0500
Received: by mail-da0-f54.google.com with SMTP id p1so161894dad.13
        for <netdev@vger.kernel.org>; Tue, 26 Feb 2013 23:25:15 -0800 (PST)
In-Reply-To: <1361949146.11403.21.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-26 at 23:12 -0800, Eric Dumazet wrote:

> I totally Nack this patch.
> 
> 1) net-next is not open.
> 
> 2) We spent enough time chasing bugs, I don't want to reintroduce new
> ones.
> 
> And this patch introduce nice bugs. No thank you.

Humm... maybe I misread the patch, I'll take another look tomorrow after
some sleep.

Thanks
