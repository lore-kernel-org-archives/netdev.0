From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] [resend] 3c509: convert to isa_driver and pnp_driver v5
Date: Mon, 3 Mar 2008 20:25:55 -0800
Message-ID: <20080303202555.3bb63526.akpm@linux-foundation.org>
References: <200801312012.43447.linux@rainbow-software.org>
	<200802021925.36552.linux@rainbow-software.org>
	<47A4D791.3050700@garzik.org>
	<200802171202.27747.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60571 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751146AbYCDE0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 23:26:49 -0500
In-Reply-To: <200802171202.27747.linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 17 Feb 2008 12:02:25 +0100 Ondrej Zary <linux@rainbow-software.org> wrote:

> this patch converts 3c509 driver to isa_driver and pnp_driver.

alpha allmodconfig:

drivers/net/3c509.c:494: error: 'el3_suspend' undeclared here (not in a function)
drivers/net/3c509.c:495: error: 'el3_resume' undeclared here (not in a function)
