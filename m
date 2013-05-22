From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ip_gre: fix kernel panic with icmp_dest_unreach
Date: Wed, 22 May 2013 04:53:30 -0700
Message-ID: <1369223610.3301.310.camel@edumazet-glaptop>
References: <D2CA09D3-A93C-48CF-A23B-DC1B76D66818@rcs-rds.ro>
	  <1369170063.3301.251.camel@edumazet-glaptop> <519C839E.1000309@rcs-rds.ro>
	 <1369222666.3301.304.camel@edumazet-glaptop> <519CB0D3.8000406@rcs-rds.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Daniel Petre <daniel.petre@rcs-rds.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f50.google.com ([209.85.210.50]:55397 "EHLO
	mail-da0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754345Ab3EVLxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 07:53:32 -0400
Received: by mail-da0-f50.google.com with SMTP id i23so1096932dad.9
        for <netdev@vger.kernel.org>; Wed, 22 May 2013 04:53:32 -0700 (PDT)
In-Reply-To: <519CB0D3.8000406@rcs-rds.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-22 at 14:49 +0300, Daniel Petre wrote:

> 
> Hello Eric,
> some machines have e1000e others have tg3 (with mtu 1524) then we have
> few gre tunnels on top of the downlink ethernet and the traffic goes up
> the router via the second ethernet interface, nothing complicated.

Nothing complicated, but I am not going to spend one hour to reproduce
the bug by guessing what you do.
