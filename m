From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Iptables-1.2.9/10 compile failure with linux 2.6.7 headers
Date: Sat, 19 Jun 2004 07:51:28 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040619.075128.106025605.yoshfuji@linux-ipv6.org>
References: <40D31EA6.5030207@ThinRope.net>
	<20040619.021818.04202102.yoshfuji@linux-ipv6.org>
	<40D3361B.5020304@ThinRope.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kalin@ThinRope.net, andrew@walrond.org
In-Reply-To: <40D3361B.5020304@ThinRope.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <40D3361B.5020304@ThinRope.net> (at Sat, 19 Jun 2004 03:36:11 +0900), Kalin KOZHUHAROV <kalin@ThinRope.net> says:

> As far as I understand from this patch, this should be applied to the system headers...

Patch is for current linux-2.5 bk tree,
not for linux-headers.

Please try to patch your kernel and set KERNEL_DIR to 
/path/to/your/kernel when you compile iptables.

Thanks.

--yoshfuji
