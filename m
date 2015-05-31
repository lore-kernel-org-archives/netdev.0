From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] netevent: remove automatic variable in
 register_netevent_notifier()
Date: Sun, 31 May 2015 00:07:33 -0700 (PDT)
Message-ID: <20150531.000733.1085288092888178065.davem@davemloft.net>
References: <1432861328-227197-1-git-send-email-long.wanglong@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	linux-kernel@vger.kernel.org, peifeiyue@huawei.com,
	wanglong@laoqinren.net
To: long.wanglong@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432861328-227197-1-git-send-email-long.wanglong@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wang Long <long.wanglong@huawei.com>
Date: Fri, 29 May 2015 01:02:08 +0000

> Remove automatic variable 'err' in register_netevent_notifier() and
> return the result of atomic_notifier_chain_register() directly.
> 
> Signed-off-by: Wang Long <long.wanglong@huawei.com>

Applied, thank you.
