From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/24] net, diet: Make FIB hash tables smaller with
 CONFIG_BASE_SMALL
Date: Mon, 05 May 2014 23:10:49 -0400 (EDT)
Message-ID: <20140505.231049.651213444049909165.davem@davemloft.net>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
	<1399328773-6531-5-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com
To: andi@firstfloor.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399328773-6531-5-git-send-email-andi@firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: Mon,  5 May 2014 15:25:53 -0700

> From: Andi Kleen <ak@linux.intel.com>
> 
> Just make the FIB hash tables much smaller for small
> kernel.
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Sounds like an exploit waiting to happen.
