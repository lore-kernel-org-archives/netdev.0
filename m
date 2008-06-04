From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] net: via-velocity.c fix sleep-with-spinlock bug during
	MTU change
Date: Wed, 4 Jun 2008 23:59:09 +0200
Message-ID: <20080604215909.GA17446@electric-eye.fr.zoreil.com>
References: <20080531184615.350bac00@infradead.org> <20080603134019.df2f51d4.akpm@linux-foundation.org> <20080603215155.GA9712@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@infradead.org>, alan@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:51315 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752792AbYFDW0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 18:26:43 -0400
Content-Disposition: inline
In-Reply-To: <20080603215155.GA9712@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu@fr.zoreil.com> :
[...]
> I'll wrap it in the next 24 hours.

... add 24 more as it starts to be ugly and I have not even considered
velocity_init_rings. :o/

-- 
Ueimor
