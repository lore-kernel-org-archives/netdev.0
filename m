From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] drivers/net: fix build warnings with CONFIG_PM_SLEEP
 disabled
Date: Mon, 7 Mar 2011 15:07:35 -0800
Message-ID: <20110307150735.3d6515f2@nehalam>
References: <20110307021450.GC31188@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org
To: Michel Lespinasse <walken@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110307021450.GC31188@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 6 Mar 2011 18:14:50 -0800
Michel Lespinasse <walken@google.com> wrote:

> This fixes a couple of build warnings when CONFIG_PM is enabled but
> CONFIG_PM_SLEEP is disabled. Applies on top of v2.6.38-rc7 - I know it's
> late, but it would be great if v2.6.38 could compile without warnings!
> 
> Signed-off-by: Michel Lespinasse <walken@google.com>

This is standard throughout all the network drivers.
Why just fix 2?


-- 
