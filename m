From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 0/4] Add cross-compilation support to eBPF samples
Date: Thu, 21 Sep 2017 11:59:35 -0700 (PDT)
Message-ID: <20170921.115935.942588432873544422.davem@davemloft.net>
References: <20170920160436.24689-1-joelaf@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        alison@she-devel.com, juri.lelli@arm.com, fengc@google.com,
        daniel@iogearbox.net, ast@kernel.org, kernel-team@android.com
To: joelaf@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170920160436.24689-1-joelaf@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joel Fernandes <joelaf@google.com>
Date: Wed, 20 Sep 2017 09:04:32 -0700

> These patches fix issues seen when cross-compiling eBPF samples on arm64.
> Compared to [1], I dropped the controversial inline-asm patch and exploring
> other options to fix it. However these patches are a step in the right
> direction and I look forward to getting them into -next and the merge window.
> 
> Changes since v3:
> - just a repost with acks
> 
> [1] https://lkml.org/lkml/2017/8/7/417

Series applied with typo in patch #4 corrected.

Thanks.
