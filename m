From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] net/wan/pc300too.c: pci_module_init to pci_register_driver
Date: Sat, 17 Feb 2007 15:27:04 -0500
Message-ID: <45D76518.7080201@garzik.org>
References: <20070214004022.4455.49724.sendpatchset@thinktank.campus.ltu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Halasa <khc@pm.waw.pl>, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Richard Knutsson <ricknu-0@student.ltu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47745 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751757AbXBQU1N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Feb 2007 15:27:13 -0500
In-Reply-To: <20070214004022.4455.49724.sendpatchset@thinktank.campus.ltu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Richard Knutsson wrote:
> Convert pci_module_init() to pci_register_driver().
> 
> Signed-off-by: Richard Knutsson <ricknu-0@student.ltu.se>
> ---
> Compile-tested with "allyes", "allmod" & "allno" on i386

applied


