From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: broadcom: Remove null check before kfree
Date: Mon, 28 Aug 2017 15:53:33 -0700 (PDT)
Message-ID: <20170828.155333.1067566141697358468.davem@davemloft.net>
References: <1503778667-4416-1-git-send-email-himanshujha199640@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarod@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: himanshujha199640@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503778667-4416-1-git-send-email-himanshujha199640@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Himanshu Jha <himanshujha199640@gmail.com>
Date: Sun, 27 Aug 2017 01:47:47 +0530

> Kfree on NULL pointer is a no-op and therefore checking is redundant.
> 
> Signed-off-by: Himanshu Jha <himanshujha199640@gmail.com>

Applied.
