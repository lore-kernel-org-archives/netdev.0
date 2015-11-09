From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tree wide: Use kvfree() than conditional
 kfree()/vfree()
Date: Mon, 09 Nov 2015 11:26:29 -0500 (EST)
Message-ID: <20151109.112629.1860510744923009883.davem@davemloft.net>
References: <1447070170-8512-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20151109121126.GD11149@quack.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: penguin-kernel@I-love.SAKURA.ne.jp, akpm@linux-foundation.org,
 linux-mm@kvack.org, linux@arm.linux.org.uk, linux-acpi@vger.kernel.org,
 drbd-user@lists.linbit.com, linux-kernel@vger.kernel.org,
 dri-devel@lists.freedesktop.org, oleg.drokin@intel.com,
 andreas.dilger@intel.com, codalist@coda.cs.cmu.edu,
 linux-mtd@lists.infradead.org, jack@suse.com,
 linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: jack@suse.cz
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20151109121126.GD11149@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Jan Kara <jack@suse.cz>
Date: Mon, 9 Nov 2015 13:11:26 +0100

> You can add
> 
> Acked-by: Jan Kara <jack@suse.com>
> 
> for the UDF and fs/xattr.c parts.

Please do not quote and entire large patch just to give an ACK.

Just quote the minimum necessary context, which is usually just
the commit message.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
