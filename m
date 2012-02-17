From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: [PATCH] net: ethernet: xilinx: Convert xilinx_axienet to module_platform_driver
Date: Fri, 17 Feb 2012 16:54:02 +0100
Message-ID: <4F3E781A.30402@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ariane Keller <ariane.keller@tik.ee.ethz.ch>,
	netdev@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34826 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371Ab2BQPyk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 10:54:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tobias Klauser <tklauser@distanz.ch> wrote:
> Follow commit db62f684. Convert the driver to use the
> module_platform_driver() macro which makes the code a bit smaller and
> simpler.
>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Acked-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>

Thanks!
