From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] cxgb3: fix GRO checksum check
Date: Mon, 08 Feb 2010 22:37:31 -0800 (PST)
Message-ID: <20100208.223731.192859791.davem@davemloft.net>
References: <20100209005544.12679.3987.stgit@speedy5.asicdesigners.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100209005544.12679.3987.stgit@speedy5.asicdesigners.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>
Date: Mon, 08 Feb 2010 16:55:44 -0800

> From: Divy Le Ray <divy@chelsio.com>
> 
> Verify the HW checksum state for frames handed to GRO processing.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied, thanks.
