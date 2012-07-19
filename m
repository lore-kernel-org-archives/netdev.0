From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: Re: [PATCH] jme: netpoll support
Date: Thu, 19 Jul 2012 10:00:10 +0800
Message-ID: <20120719015637.M13815@cooldavid.org>
References: <18143736.brt1iGhlQ1@al> <20120718.094524.264223189588300582.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=utf-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, lekensteyn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:58671 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752243Ab2GSCKg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 22:10:36 -0400
In-Reply-To: <20120718.094524.264223189588300582.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Jul 2012 09:45:24 -0700 (PDT), David Miller wrote
> From: Lekensteyn <lekensteyn@gmail.com>
> Date: Tue, 17 Jul 2012 18:29:34 +0200
> 
> > From: Peter Wu <lekensteyn@gmail.com>
> > 
> > This patch adds the netpoll function to support netconsole. Tested and works
> > fine on my "JMC250 PCI Express Gigabit Ethernet Controller" (PCI ID 0250).
> > 
> > Signed-off-by: Peter Wu <lekensteyn@gmail.com>
> 
> Applied to net-next
> 
> I really wonder if this driver works on SMP systems at all.
Hi davem:

I wrote/tested this driver on SMP system at very beginning.
In face some of the design was aimed for SMP systems.
Is there any obvious bug or something I should be aware of?

Guo-Fu Tseng
