From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/2] chelsio: 1G board support
Date: Fri, 17 Nov 2006 17:25:39 -0800
Message-ID: <20061117172539.1c9a512c@zqx3.pdx.osdl.net>
References: <Pine.LNX.4.64.0611131408010.32659@potato.cts.ucla.edu>
	<455A49D7.4050106@garzik.org>
	<20061114153725.730fcd6d@freekitty>
	<Pine.LNX.4.64.0611141540110.3416@potato.cts.ucla.edu>
	<20061115170320.5078073a@freekitty>
	<20061115190903.d61be44f.akpm@osdl.org>
	<20061115213532.0d2350ba@localhost.localdomain>
	<20061115215206.6bee3534.akpm@osdl.org>
	<20061117172057.61015224@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:22187 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1756122AbWKRB0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 20:26:09 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061117172057.61015224@zqx3.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is the addon to the Chelsio 10G driver to support their 1G boards.
I extracted this from the vendor driver version 2.2 code, and cleaned it up
to match the mainline code.

I don't have the hardware, so it probably doesn't work as is.  But getting
it to development kernel will get others to fix it.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Patch is large 80K so please download from:
	http://developer.osdl.org/shemminger/prototypes/chelsio-1g.patch.gz
