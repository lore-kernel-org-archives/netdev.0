From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2]: softirq: Add support for triggering softirq work
 on softirqs.
Date: Sat, 20 Sep 2008 10:42:49 -0700
Message-ID: <20080920104249.c079b6d2.akpm@linux-foundation.org>
References: <20080919.234832.127229997.davem@davemloft.net>
	<20080920004608.a3123052.akpm@linux-foundation.org>
	<20080920.035602.226564809.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com, steffen.klassert@secunet.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52235 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750796AbYITRnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 13:43:07 -0400
In-Reply-To: <20080920.035602.226564809.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 20 Sep 2008 03:56:02 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> I've got your kerneldoc right here buddy boy...

thanks.  It's surprising how much that improves the code review.

> +/***

/** is sufficient & conventional for kerneldoc.

