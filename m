From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlge: avoid format string exposure in workqueue
Date: Thu, 06 Apr 2017 13:37:49 -0700 (PDT)
Message-ID: <20170406.133749.106162564910238546.davem@davemloft.net>
References: <20170405213903.GA4505@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, harish.patil@cavium.com,
        manish.chopra@cavium.com, Dept-GELinuxNICDev@cavium.com,
        netdev@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170405213903.GA4505@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Wed, 5 Apr 2017 14:39:03 -0700

> While unlikely, this makes sure the workqueue name won't be processed
> as a format string.
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
