From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2] net: remove NR_CPUS arrays in net/core/dev.c
Date: Fri, 02 May 2008 16:43:23 -0700 (PDT)
Message-ID: <20080502.164323.36054038.davem@davemloft.net>
References: <200805022039.m42KdQA3013598@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, travis@sgi.com, jmorris@namei.org,
	kaber@trash.net, kuznet@ms2.inr.ac.ru
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33813
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1765796AbYEBXnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 19:43:23 -0400
In-Reply-To: <200805022039.m42KdQA3013598@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Fri, 02 May 2008 13:39:26 -0700

> Remove the fixed size channels[NR_CPUS] array in net/core/dev.c and
> dynamically allocate array based on nr_cpu_ids.
> 
> Signed-off-by: Mike Travis <travis@sgi.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied, thanks.
