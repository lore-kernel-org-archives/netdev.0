From: Pavel Machek <pavel@suse.cz>
Subject: Re: [0/9] pohmelfs: The Great Southern Trendkill release.
Date: Fri, 26 Dec 2008 20:26:19 +0100
Message-ID: <20081226192618.GC1761@ucw.cz>
References: <1230301130-1325-1-git-send-email-zbe@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, pohmelfs@ioremap.net,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Evgeniy Polyakov <zbr@ioremap.net>
To: Evgeniy Polyakov <zbe@ioremap.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1230301130-1325-1-git-send-email-zbe@ioremap.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> POHMELFS stands for Parallel Optimized Host Message Exchange Layered File System.
> 
> This is a high performance network filesystem with local coherent cache of
> data and metadata. Its main goal is distributed parallel processing of data.
> 
> POHMELFS is a kernel client for the developed distributed parallel internet
> filesystem. As it exists today, it is a high-performance parallel network
> filesystem with ability to balance reading from multiple hosts and simultaneously
> write data to multiple hosts.

So ocfs2 -alike fs?

> Signed-off-by: Evgeniy Polyakov <zbr@ioremap.net>

Do you think its ready for -mm?

Can it survive test such as paralel kernel compilation(s), fsx, etc?

How fast is it compared to nfs? to ext3 over fast network?
								Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
