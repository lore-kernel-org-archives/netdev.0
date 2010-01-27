From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 2/4] ar7: implement clock API
Date: Wed, 27 Jan 2010 14:54:06 +0100
Message-ID: <20100127135405.GB18247@linux-mips.org>
References: <201001032117.07022.florian@openwrt.org>
 <201001121015.27867.florian@openwrt.org>
 <201001270910.06224.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mips@linux-mips.org, Wim Van Sebroeck <wim@iguana.be>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:44311 "EHLO
	eddie.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754842Ab0A0NyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 08:54:04 -0500
Received: from localhost.localdomain ([127.0.0.1]:49897 "EHLO h5.dl5rb.org.uk"
        rhost-flags-OK-OK-OK-FAIL) by eddie.linux-mips.org with ESMTP
        id S1493545Ab0A0NyC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 27 Jan 2010 14:54:02 +0100
Content-Disposition: inline
In-Reply-To: <201001270910.06224.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 27, 2010 at 09:10:06AM +0100, Florian Fainelli wrote:

> This patch makes the ar7 clock code implement the
> Linux clk API. Drivers using the various clocks
> available in the SoC are updated accordingly.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>
> Acked-by: Wim Van Sebroeck <wim@iguana.be>

Thanks; queued for 2.6.34.

  Ralf
