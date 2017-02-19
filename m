From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] uapi: fix linux/rds.h userspace compilation
 errors
Date: Sun, 19 Feb 2017 18:16:28 -0500 (EST)
Message-ID: <20170219.181628.2287358126814343624.davem@davemloft.net>
References: <20170215200740.GH1028@altlinux.org>
        <20170216150512.GD13804@altlinux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ldv@altlinux.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170216150512.GD13804@altlinux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Dmitry V. Levin" <ldv@altlinux.org>
Date: Thu, 16 Feb 2017 18:05:13 +0300

> Consistently use types from linux/types.h to fix the following
> linux/rds.h userspace compilation errors:
 ...
> Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>

Applied.
