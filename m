From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/3] ne: MIPS: Use platform_driver for ne on RBTX49XX
Date: Sat, 28 Apr 2007 11:08:19 -0400
Message-ID: <46336363.4030609@garzik.org>
References: <20070425.015549.108742168.anemo@mba.ocn.ne.jp> <20070425.020355.70477311.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org,
	ralf@linux-mips.org, sshtylyov@ru.mvista.com
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51958 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751306AbXD1PIW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 11:08:22 -0400
In-Reply-To: <20070425.020355.70477311.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Atsushi Nemoto wrote:
> On Wed, 25 Apr 2007 01:55:49 +0900 (JST), Atsushi Nemoto <anemo@mba.ocn.ne.jp> wrote:
>> This patch lets RBTX49XX boards use generic platform_driver interface
>> for the ne driver.
> 
> This patch obsolates a patch I send on 1 Mar.
> 
>> Subject: [PATCH] Fix broken RBTX4927 support in ne.c
>> Message-Id: <20070301.012223.129448787.anemo@mba.ocn.ne.jp>
>> Date: 	Thu, 01 Mar 2007 01:22:23 +0900 (JST)
> 
> I revoke this old patch if new patch was acceptable.

I do not see the old patch in my queue (my apologies!), so all is well.

	Jeff



