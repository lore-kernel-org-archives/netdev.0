From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 10/10] forcedeth: work around NULL skb dereference crash
Date: Mon, 2 Apr 2007 13:53:25 +0200
Message-ID: <20070402115325.GA945@elte.hu>
References: <200703270547.l2R5lTZg008278@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, aabdulla@nvidia.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:35270 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933973AbXDBLxf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Apr 2007 07:53:35 -0400
Content-Disposition: inline
In-Reply-To: <200703270547.l2R5lTZg008278@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* akpm@linux-foundation.org <akpm@linux-foundation.org> wrote:

> From: Ingo Molnar <mingo@elte.hu>
> 
> work around a NULL skb dereference crash that occurs during high load.
> 
> Signed-off-by: Ingo Molnar <mingo@elte.hu>
> Cc: Ayaz Abdulla <aabdulla@nvidia.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

ping? No reaction from the forcedeth.c maintainer, yet.

	Ingo
