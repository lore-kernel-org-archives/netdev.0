From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 17/19] tools: bpf_jit_disasm: make
 get_last_jit_image return unsigned
Date: Mon, 28 Sep 2015 22:18:17 -0700 (PDT)
Message-ID: <20150928.221817.1088984521154137505.davem@davemloft.net>
References: <560446A2.2020907@iogearbox.net>
	<1443163543-25733-1-git-send-email-a.hajda@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, b.zolnierkie@samsung.com,
	m.szyprowski@samsung.com, netdev@vger.kernel.org
To: a.hajda@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443163543-25733-1-git-send-email-a.hajda@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrzej Hajda <a.hajda@samsung.com>
Date: Fri, 25 Sep 2015 08:45:43 +0200

> The function returns always non-negative values.
> 
> The problem has been detected using proposed semantic patch
> scripts/coccinelle/tests/assign_signed_to_unsigned.cocci [1].
> 
> [1]: http://permalink.gmane.org/gmane.linux.kernel/2046107
> 
> Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
> ---
> v2: fixed indentation

Applied, thanks.
