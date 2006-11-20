From: Alan <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC: 2.6 patch] remove the broken SKMC driver
Date: Mon, 20 Nov 2006 23:31:53 +0000
Message-ID: <20061120233153.34bd814d@localhost.localdomain>
References: <20061120210648.GB31879@stusta.de>
	<20061120140115.4cdec66a@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jejb@steeleye.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:54167 "EHLO
	lxorguk.ukuu.org.uk") by vger.kernel.org with ESMTP
	id S1030507AbWKTXde (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 18:33:34 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061120140115.4cdec66a@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Nov 2006 14:01:15 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Are there any working microchannel drivers?  Can we drop support for microchannel
> at the bus level?

Mr Bottomley has MCA bus. I don't think anyone else on the planet cares
so maybe we should drop all non voyager MCA bus support and make MCA
depend on VOYAGER ?

Alan
