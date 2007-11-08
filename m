From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: ax88796: add superh to kconfig dependencies
Date: Thu, 8 Nov 2007 17:12:35 +0900
Message-ID: <20071108081235.GA31906@linux-sh.org>
References: <20071108073105.3996.70418.sendpatchset@clockwork.opensource.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ben-linux@fluff.org,
	akpm@linux-foundation.org, jeff@garzik.org
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pip9.gyao.ne.jp ([61.122.117.247]:56397 "EHLO mx.gate01.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751419AbXKHInp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2007 03:43:45 -0500
Content-Disposition: inline
In-Reply-To: <20071108073105.3996.70418.sendpatchset@clockwork.opensource.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 08, 2007 at 04:31:05PM +0900, Magnus Damm wrote:
> ax88796: add superh to kconfig dependencies
> 
> This patch adds sh architecture support to the ax88796 kconfig.
> 
> Signed-off-by: Magnus Damm <damm@igel.co.jp>
> ---
> 
>  This patch was posted about a month ago but never picked up:
>  http://www.mail-archive.com/netdev@vger.kernel.org/msg50018.html
>  The rest of the sh support is already included in rc1. Please apply.
> 
And as per:

	http://www.mail-archive.com/netdev@vger.kernel.org/msg50027.html

Still-acked-by: Paul Mundt <lethal@linux-sh.org>
