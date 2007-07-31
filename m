From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] make nf_ct_ipv6_skip_exthdr() static
Date: Mon, 30 Jul 2007 18:05:07 -0700 (PDT)
Message-ID: <20070730.180507.101870991.davem@davemloft.net>
References: <20070729145846.GZ16817@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yasuyuki.kozakai@toshiba.co.jp, kaber@trash.net,
	netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bunk@stusta.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S940311AbXGaBFb@vger.kernel.org>
In-Reply-To: <20070729145846.GZ16817@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Sun, 29 Jul 2007 16:58:46 +0200

> nf_ct_ipv6_skip_exthdr() can now become static.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied.
