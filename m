From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/13] smsc911x: Use lockdep_assert_held instead of
 home grown buggy construct
Date: Tue, 27 Mar 2012 21:32:44 -0400 (EDT)
Message-ID: <20120327.213244.340230223876758625.davem@davemloft.net>
References: <1332895637-32572-1-git-send-email-andi@firstfloor.org>
	<1332895637-32572-11-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	ak@linux.intel.com, netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1332895637-32572-11-git-send-email-andi@firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: Tue, 27 Mar 2012 17:47:14 -0700

> From: Andi Kleen <ak@linux.intel.com>
> 
> Cc: netdev@vger.kernel.org
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Acked-by: David S. Miller <davem@davemloft.net>
