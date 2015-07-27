From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 net-next 0/3] ARM BPF JIT features
Date: Mon, 27 Jul 2015 14:57:58 -0700 (PDT)
Message-ID: <20150727.145758.2195351837197349303.davem@davemloft.net>
References: <20150724.223155.121697079062172205.davem@davemloft.net>
	<1438002411-8709-1-git-send-email-nschichan@freebox.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, mgherzan@gmail.com,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux@arm.linux.org.uk, ast@plumgrid.com
To: nschichan@freebox.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438002411-8709-1-git-send-email-nschichan@freebox.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Schichan <nschichan@freebox.fr>
Date: Mon, 27 Jul 2015 15:06:48 +0200

> This series adds support for more instructions to the ARM BPF JIT
> namely skb netdevice type retrieval, skb payload offset retrieval, and
> skb packet type retrieval.
> 
> This allows 35 tests to use the JIT instead of 29 before.
> 
> This series depends on the "BPF JIT fixes for ARM" serie sent earlier.

Series applied, thanks.
