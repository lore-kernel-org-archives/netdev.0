From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ne: Do not use slashes in irq name string
Date: Tue, 16 Mar 2010 14:28:37 -0700 (PDT)
Message-ID: <20100316.142837.214369316.davem@davemloft.net>
References: <1268753260-5632-1-git-send-email-anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: anemo@mba.ocn.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41923
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754364Ab0CPV2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 17:28:15 -0400
In-Reply-To: <1268753260-5632-1-git-send-email-anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Date: Wed, 17 Mar 2010 00:27:40 +0900

> This patch fixes following warning introduced by commit
> 12bac0d9f4dbf3445a0319beee848d15fa32775e ("proc: warn on non-existing
> proc entries"):
> 
> WARNING: at /work/mips-linux/make/linux/fs/proc/generic.c:316 __xlate_proc_name+0xe0/0xe8()
> name 'RBHMA4X00/RTL8019'
> 
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>

Applied.
