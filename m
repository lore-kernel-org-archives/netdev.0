From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/13] irda: remove spin_is_locked
Date: Tue, 27 Mar 2012 21:32:37 -0400 (EDT)
Message-ID: <20120327.213237.1580978953589022069.davem@davemloft.net>
References: <1332895637-32572-1-git-send-email-andi@firstfloor.org>
	<1332895637-32572-9-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	ak@linux.intel.com, netdev@vger.kernel.org, samuel@sortiz.org
To: andi@firstfloor.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1332895637-32572-9-git-send-email-andi@firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: Tue, 27 Mar 2012 17:47:12 -0700

> From: Andi Kleen <ak@linux.intel.com>
> 
> It's hard to imagine how this spin_is_locked debugging check is not
> totally racy.  Remove it.
> 
> Cc: netdev@vger.kernel.org
> Cc: samuel@sortiz.org
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Acked-by: David S. Miller <davem@davemloft.net>
