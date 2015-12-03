From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH] arm64: bpf: add 'store immediate' instruction
Date: Thu, 03 Dec 2015 11:38:46 -0500 (EST)
Message-ID: <20151203.113846.853547663758521483.davem@davemloft.net>
References: <1448922247-5692-1-git-send-email-yang.shi@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com,
	zlim.lnx@gmail.com, xi.wang@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linaro-kernel@lists.linaro.org
To: yang.shi@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448922247-5692-1-git-send-email-yang.shi@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yang Shi <yang.shi@linaro.org>
Date: Mon, 30 Nov 2015 14:24:07 -0800

> aarch64 doesn't have native store immediate instruction, such operation
> has to be implemented by the below instruction sequence:
> 
> Load immediate to register
> Store register
> 
> Signed-off-by: Yang Shi <yang.shi@linaro.org>

Applied, thanks.
