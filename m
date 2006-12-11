From: Vitaly Bordug <vbordug@ru.mvista.com>
Subject: Re: [PATCH] [FS_ENET] OF-related update for FEC and SCC MAC's
Date: Mon, 11 Dec 2006 21:36:28 +0300
Message-ID: <20061211213628.23dcc319@vitb.ru.mvista.com>
References: <20061211180048.17991.59030.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linuxppc-embedded@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:35167 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1763007AbWLKSgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 13:36:19 -0500
To: Vitaly Bordug <vbordug@ru.mvista.com>
In-Reply-To: <20061211180048.17991.59030.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 11 Dec 2006 21:00:49 +0300
Vitaly Bordug <vbordug@ru.mvista.com> wrote:

> 
> Updated direct resource pass with ioremap call, make it grant proper IRQ
> mapping, stuff incompatible with the new approach were respectively put  under 
> #ifndef CONFIG_PPC_MERGE.

Hrm, Signed-off-by: missed, I'll resend, sorry about that.
-- 
Sincerely, 
Vitaly
