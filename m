From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH] Remove always-true tests in irq handlers
Date: Fri, 26 Oct 2007 13:02:13 +0100
Message-ID: <20071026120213.GA32421@linux-mips.org>
References: <9799624f63e093aa915947aea8fb1b8a5df959a1.1193390973.git.jeff@garzik.org> <53d6c8049d4c3999a9d33d73e385d6161b5de2b7.1193390974.git.jeff@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org,
	tony.luck@intel.com, linux-ia64@vger.kernel.org,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-ia64-owner@vger.kernel.org>
Received: from localhost.localdomain ([127.0.0.1]:2268 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20027423AbXJZMCT (ORCPT <rfc822;netdev@vger.kernel.org>
	+ 2 others); Fri, 26 Oct 2007 13:02:19 +0100
Content-Disposition: inline
In-Reply-To: <53d6c8049d4c3999a9d33d73e385d6161b5de2b7.1193390974.git.jeff@garzik.org>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 26, 2007 at 05:40:24AM -0400, Jeff Garzik wrote:

> In these drivers, dev_id is always non-NULL.
> 
> Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
> ---
>  arch/ia64/hp/sim/simeth.c                   |    5 -----
>  arch/mips/pmc-sierra/msp71xx/msp_hwbutton.c |    5 +----

Acked-by: Ralf Baechle <ralf@linux-mips.org>

  Ralf
