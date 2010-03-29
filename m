From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: offical fix for CVE-2009-4537 (overlength frame
 DMAs)
Date: Mon, 29 Mar 2010 13:17:29 -0700 (PDT)
Message-ID: <20100329.131729.125560878.davem@davemloft.net>
References: <20100329160356.GC22733@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	michael.s.gilbert@gmail.com, romieu@fr.zoreil.com,
	eric.dumazet@gmail.com
To: nhorman@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100329160356.GC22733@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 29 Mar 2010 12:03:56 -0400

> Official patch to fix the r8169 frame length check error.
 ...
> Signed-off-by: Neil Horman <nhorman@redhat.com>

Applied, thanks a lot Neil.
