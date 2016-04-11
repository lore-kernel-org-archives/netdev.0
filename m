From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fjes: Use resource_size
Date: Mon, 11 Apr 2016 15:02:56 -0400 (EDT)
Message-ID: <20160411.150256.533360064398081718.davem@davemloft.net>
References: <1460370497-10221-1-git-send-email-vaishali.thakkar@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: izumi.taku@jp.fujitsu.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: vaishali.thakkar@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460370497-10221-1-git-send-email-vaishali.thakkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vaishali Thakkar <vaishali.thakkar@oracle.com>
Date: Mon, 11 Apr 2016 15:58:17 +0530

> Use the function resource_size instead of explicit computation.
> 
> Problem found using Coccinelle.
> 
> Signed-off-by: Vaishali Thakkar <vaishali.thakkar@oracle.com>

Applied.
