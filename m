From: Peter Korsgaard <peter@korsgaard.com>
Subject: Re: [PATCH 1/2] net: ethernet: cpsw: Search childs for slave nodes
Date: Fri, 04 Oct 2013 17:24:39 +0200
Message-ID: <87ob75jbyg.fsf@dell.be.48ers.dk>
References: <1380890680-30941-1-git-send-email-mpa@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>, netdev@vger.kernel.org,
	kernel@pengutronix.de, Florian Fainelli <florian@openwrt.org>,
	linux-arm-kernel@lists.infradead.org
To: Markus Pargmann <mpa@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:58143 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754027Ab3JDPYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 11:24:42 -0400
Received: by mail-ea0-f176.google.com with SMTP id q16so1856929ead.7
        for <netdev@vger.kernel.org>; Fri, 04 Oct 2013 08:24:41 -0700 (PDT)
In-Reply-To: <1380890680-30941-1-git-send-email-mpa@pengutronix.de> (Markus
	Pargmann's message of "Fri, 4 Oct 2013 14:44:39 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Markus" == Markus Pargmann <mpa@pengutronix.de> writes:

 Markus> The current implementation searches the whole DT for nodes named
 Markus> "slave".

 Markus> This patch changes it to search only child nodes for slaves.

 Markus> Signed-off-by: Markus Pargmann <mpa@pengutronix.de>

Acked-by: Peter Korsgaard <jacmet@sunsite.dk>

-- 
Bye, Peter Korsgaard
