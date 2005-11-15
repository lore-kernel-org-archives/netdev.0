From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH]IPv6: small fix for ipv6_dev_get_saddr(...)
Date: Mon, 14 Nov 2005 21:42:55 -0800 (PST)
Message-ID: <20051114.214255.15845939.davem@davemloft.net>
References: <43786A16.9070100@21cn.com>
	<20051115.102237.101993116.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yanzheng@21cn.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751334AbVKOFmt@vger.kernel.org>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20051115.102237.101993116.yoshfuji@linux-ipv6.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 15 Nov 2005 10:22:37 +0900 (JST)

> In article <43786A16.9070100@21cn.com> (at Mon, 14 Nov 2005 18:42:30 +0800), Yan Zheng <yanzheng@21cn.com> says:
> 
> > The "score.rule++" doesn't make any sense for me. 
> > According to codes above, I think it should be "hiscore.rule++;" .
> 
> Oops, you're right.
> 
> > Signed-off-by: Yan Zheng<yanzheng@21cn.com>
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
