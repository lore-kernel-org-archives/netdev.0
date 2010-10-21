From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2.6.36-rc7] net/neighbour: cancel_delayed_work() +
 flush_scheduled_work() -> cancel_delayed_work_sync()
Date: Thu, 21 Oct 2010 04:29:13 -0700 (PDT)
Message-ID: <20101021.042913.13752984.davem@davemloft.net>
References: <4CBDC19A.60709@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tj@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CBDC19A.60709@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tejun Heo <tj@kernel.org>
Date: Tue, 19 Oct 2010 18:04:42 +0200

> flush_scheduled_work() is going away.  Prepare for it.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>

Applied.
