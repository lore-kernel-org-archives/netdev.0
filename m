From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 10/10] PLIP driver: convert killed_timer_sem to completion
Date: Mon, 17 Dec 2007 20:18:24 -0500
Message-ID: <47671FE0.40500@garzik.org>
References: <200712140003.lBE031Fa025539@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matthias.kaehlcke@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34187 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762896AbXLRBS0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 20:18:26 -0500
In-Reply-To: <200712140003.lBE031Fa025539@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Matthias Kaehlcke <matthias.kaehlcke@gmail.com>
> 
> PLIP driver: convert the semaphore killed_timer_sem to a completion
> 
> Signed-off-by: Matthias Kaehlcke <matthias.kaehlcke@gmail.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

applied #upstream


