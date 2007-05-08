From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/5] ne: Add platform_driver
Date: Tue, 08 May 2007 01:23:20 -0400
Message-ID: <46400948.9060007@garzik.org>
References: <20070501.002731.104031408.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org,
	ralf@linux-mips.org, sshtylyov@ru.mvista.com,
	akpm@linux-foundation.org
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54432 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967905AbXEHFX0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 01:23:26 -0400
In-Reply-To: <20070501.002731.104031408.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Atsushi Nemoto wrote:
> Add a platform_driver interface to ne driver.
> (Existing legacy ports did not covered by this ne_driver for now)
> 
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
> ---
>  drivers/net/ne.c |   91 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 files changed, 89 insertions(+), 2 deletions(-)

applied 1-5


