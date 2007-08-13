From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: drivers/net/tokenring/3c359.c
Date: Mon, 13 Aug 2007 14:59:24 +0100
Message-ID: <20070813145924.6cc367cb@the-village.bc.nu>
References: <1187000010.29518.27.camel@bluegenie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mikep@linuxtr.net, netdev@vger.kernel.org, linux-tr@linuxtr.net,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	kernel-janitors <kernel-janitors@lists.osdl.org>
To: surya.prabhakar@wipro.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:59014 "EHLO
	the-village.bc.nu" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S945793AbXHMNvz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2007 09:51:55 -0400
In-Reply-To: <1187000010.29518.27.camel@bluegenie>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 13 Aug 2007 15:43:30 +0530
Surya Prabhakar N <surya.prabhakar@wipro.com> wrote:

> Hi,
>    Replacing kmalloc with kzalloc and cleaning up memset in 
> drivers/net/tokenring/3c359.c
> 
> 
> Signed-off-by: Surya Prabhakar <surya.prabhakar@wipro.com>

Acked-by: Alan Cox <alan@redhat.com>
