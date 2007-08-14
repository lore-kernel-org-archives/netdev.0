From: Jeff Garzik <jeff@garzik.org>
Subject: Re: drivers/net/tokenring/3c359.c
Date: Tue, 14 Aug 2007 01:50:15 -0400
Message-ID: <46C14297.1050800@garzik.org>
References: <1187000010.29518.27.camel@bluegenie>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mikep@linuxtr.net, netdev@vger.kernel.org, linux-tr@linuxtr.net,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	kernel-janitors <kernel-janitors@lists.osdl.org>
To: surya.prabhakar@wipro.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52063 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754897AbXHNFuV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:50:21 -0400
In-Reply-To: <1187000010.29518.27.camel@bluegenie>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Surya Prabhakar N wrote:
> Hi,
>    Replacing kmalloc with kzalloc and cleaning up memset in 
> drivers/net/tokenring/3c359.c
> 
> 
> Signed-off-by: Surya Prabhakar <surya.prabhakar@wipro.com>

applied


