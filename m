From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH][ipcomp6] don't check vfree() argument for NULL.
Date: Sat, 04 Feb 2006 15:50:42 -0800 (PST)
Message-ID: <20060204.155042.92905949.davem@davemloft.net>
References: <200602042049.44151.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mk@linux-ipv6.org, linux-kernel@vger.kernel.org, pekkas@netcore.fi,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964884AbWBDXut@vger.kernel.org>
To: jesper.juhl@gmail.com
In-Reply-To: <200602042049.44151.jesper.juhl@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jesper.juhl@gmail.com>
Date: Sat, 4 Feb 2006 20:49:44 +0100

> vfree does it's own NULL checking, so checking a pointer before handing
> it to vfree is pointless.
> 
> Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>

Applied to net-2.6.17, thanks.
