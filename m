From: Stefano Brivio <stefano.brivio@polimi.it>
Subject: Re: [Ubuntu PATCH] Broadcom wireless patch, PCIE/Mactel support
Date: Thu, 15 Jun 2006 13:32:20 +0200
Message-ID: <20060615133220.57d8dd26@localhost>
References: <44909A3F.4090905@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, mb@bu3sch.de,
	akpm <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.polimi.it ([131.175.12.3]:41903 "EHLO polimi.it")
	by vger.kernel.org with ESMTP id S1030240AbWFOLcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2006 07:32:48 -0400
To: Randy Dunlap <randy.dunlap@oracle.com>
In-Reply-To: <44909A3F.4090905@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Jun 2006 16:22:39 -0700
Randy Dunlap <randy.dunlap@oracle.com> wrote:

> From: Matthew Garrett <mjg59@srcf.ucam.org>
> 
> Broadcom wireless patch, PCIE/Mactel support
> 
> http://www.kernel.org/git/?p=linux/kernel/git/bcollins/ubuntu-dapper.git;a=commitdiff;h=1373a8487e911b5ee204f4422ddea00929c8a4cc
> 
> This patch adds support for PCIE cores to the bcm43xx driver. This is
> needed for wireless to work on the Intel imacs. I've submitted it to
> bcm43xx upstream.

NACK.
This has been superseded by my patchset:
http://www.mail-archive.com/bcm43xx-dev@lists.berlios.de/msg01267.html

I'm still waiting for more testing so I didn't request merging to mainline
yet. Plus, this patch is copied from this one:
http://www.mail-archive.com/bcm43xx-dev@lists.berlios.de/msg00919.html
which is wrong. Please see my patchset and new specs for reference.

PS: Next time, don't be rude and send patches to the maintainers.


-- 
Ciao
Stefano
