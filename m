From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [Ubuntu PATCH] Broadcom wireless patch, PCIE/Mactel support
Date: Thu, 15 Jun 2006 16:07:15 +0200
Message-ID: <200606151607.15570.mb@bu3sch.de>
References: <44909A3F.4090905@oracle.com> <20060615133220.57d8dd26@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, mb@bu3sch.de,
	akpm <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:22986
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751427AbWFOOIs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jun 2006 10:08:48 -0400
To: Stefano Brivio <stefano.brivio@polimi.it>
In-Reply-To: <20060615133220.57d8dd26@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 15 June 2006 13:32, Stefano Brivio wrote:
> On Wed, 14 Jun 2006 16:22:39 -0700
> Randy Dunlap <randy.dunlap@oracle.com> wrote:
> 
> > From: Matthew Garrett <mjg59@srcf.ucam.org>
> > 
> > Broadcom wireless patch, PCIE/Mactel support
> > 
> > http://www.kernel.org/git/?p=linux/kernel/git/bcollins/ubuntu-dapper.git;a=commitdiff;h=1373a8487e911b5ee204f4422ddea00929c8a4cc
> > 
> > This patch adds support for PCIE cores to the bcm43xx driver. This is
> > needed for wireless to work on the Intel imacs. I've submitted it to
> > bcm43xx upstream.
> 
> NACK.
> This has been superseded by my patchset:
> http://www.mail-archive.com/bcm43xx-dev@lists.berlios.de/msg01267.html
> 
> I'm still waiting for more testing so I didn't request merging to mainline
> yet. Plus, this patch is copied from this one:
> http://www.mail-archive.com/bcm43xx-dev@lists.berlios.de/msg00919.html
> which is wrong. Please see my patchset and new specs for reference.

I told by local computer stuff distributor to order a PCIe card.
He was not able to find one, yet. But I would like to test the patch
first. Well, if someone could tell me the exact name of a bcm43xx PCIe
card, it would be easier, perhaps.

-- 
Greetings Michael.
