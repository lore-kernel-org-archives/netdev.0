From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ptp: make ptp_clock_info const
Date: Tue, 22 Aug 2017 11:05:19 -0700 (PDT)
Message-ID: <20170822.110519.542870126131353234.davem@davemloft.net>
References: <1503336672-22918-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, richardcochran@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bhumirks@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503336672-22918-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhumika Goyal <bhumirks@gmail.com>
Date: Mon, 21 Aug 2017 23:01:12 +0530

> Make these const as they are only used in a copy operation.
> Done using Coccinelle.
 ...
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Applied.
