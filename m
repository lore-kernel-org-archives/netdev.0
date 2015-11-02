From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bpf: convert hashtab lock to raw lock
Date: Mon, 02 Nov 2015 15:47:39 -0500 (EST)
Message-ID: <20151102.154739.1348519530295656614.davem@davemloft.net>
References: <1446243386-26582-1-git-send-email-yang.shi@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, rostedt@goodmis.org, linux-kernel@vger.kernel.org,
	linux-rt-users@vger.kernel.org, netdev@vger.kernel.org,
	linaro-kernel@lists.linaro.org
To: yang.shi@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446243386-26582-1-git-send-email-yang.shi@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yang Shi <yang.shi@linaro.org>
Date: Fri, 30 Oct 2015 15:16:26 -0700

> When running bpf samples on rt kernel, it reports the below warning:
 ...
> Convert hashtab lock to raw lock to avoid such warning.
> 
> Signed-off-by: Yang Shi <yang.shi@linaro.org>

Applied to net-next, thanks.
