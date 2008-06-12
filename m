From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 07/13] smc911x: remove unused 8-bit I/O operations
Date: Wed, 11 Jun 2008 22:50:55 -0400
Message-ID: <48508F0F.80200@garzik.org>
References: <200806092333.m59NXrU8014688@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, magnus.damm@gmail.com, damm@igel.co.jp,
	lethal@linux-sh.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40490 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755510AbYFLCu6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2008 22:50:58 -0400
In-Reply-To: <200806092333.m59NXrU8014688@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Magnus Damm <magnus.damm@gmail.com>
> 
> Remove unused SMC_inb() and SMC_outb() functions.
> 
> Signed-off-by: Magnus Damm <damm@igel.co.jp>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Paul Mundt <lethal@linux-sh.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---

applied 7-13



