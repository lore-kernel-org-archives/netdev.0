From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] kbuild: remove unnecessary "obj- := dummy.o" trick
Date: Tue, 09 Sep 2014 20:40:20 -0700 (PDT)
Message-ID: <20140909.204020.352836914323089696.davem@davemloft.net>
References: <1410258381-7088-1-git-send-email-yamada.m@jp.panasonic.com>
	<1410258381-7088-2-git-send-email-yamada.m@jp.panasonic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kbuild@vger.kernel.org, ben-linux@fluff.org,
	kgene.kim@samsung.com, linux@arm.linux.org.uk,
	mturquette@linaro.org, laurent.pinchart+renesas@ideasonboard.com,
	horms+renesas@verge.net.au, geert@linux-m68k.org,
	wsa@sang-engineering.com, takasi-y@ops.dti.ne.jp,
	ulrich.hecht@gmail.com, linux-arm-kernel@lists.infradead.org,
	linux-samsung-soc@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: yamada.m@jp.panasonic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410258381-7088-2-git-send-email-yamada.m@jp.panasonic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahiro Yamada <yamada.m@jp.panasonic.com>
Date: Tue,  9 Sep 2014 19:26:19 +0900

> In these Makefiles, at least one of "obj-y" and "obj-" is non-empty,
> hence built-in.o is always created without such a trick.
> 
> Signed-off-by: Masahiro Yamada <yamada.m@jp.panasonic.com>

For networking:

Acked-by: David S. Miller <davem@davemloft.net>
