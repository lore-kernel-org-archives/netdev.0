From: Andrew Morton <akpm@osdl.org>
Subject: Re: [git patches] net driver updates
Date: Sat, 20 May 2006 09:20:33 -0700
Message-ID: <20060520092033.7d404315.akpm@osdl.org>
References: <20060520042856.GA7218@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: torvalds@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:7095 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751420AbWETQWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 May 2006 12:22:41 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <20060520042856.GA7218@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jeff@garzik.org> wrote:
>
> Andrew Morton:
>        revert "forcedeth: fix multi irq issues"

Manfred just found the fix for this, so we should no longer need to revert.
