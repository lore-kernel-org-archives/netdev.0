From: David Miller <davem@davemloft.net>
Subject: Re: call panic if nl_table allocation fails
Date: Tue, 29 Aug 2006 02:15:46 -0700 (PDT)
Message-ID: <20060829.021546.85419569.davem@davemloft.net>
References: <20060823113740.GA7834@miraclelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net, akpm@osdl.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932244AbWH2JQP@vger.kernel.org>
To: mita@miraclelinux.com
In-Reply-To: <20060823113740.GA7834@miraclelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Akinobu Mita <mita@miraclelinux.com>
Date: Wed, 23 Aug 2006 20:37:40 +0900

> This patch makes crash happen if initialization of nl_table fails
> in initcalls. It is better than getting use after free crash later.
> 
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Akinobu Mita <mita@miraclelinux.com>

Patch applied, thank you.
