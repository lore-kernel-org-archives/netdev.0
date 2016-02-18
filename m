From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] lance: Return correct error code
Date: Thu, 18 Feb 2016 14:58:59 -0500 (EST)
Message-ID: <20160218.145859.1842263482402756546.davem@davemloft.net>
References: <20160217150326.GA3116@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	julia.lawall@lip6.fr
To: amitoj1606@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160217150326.GA3116@amitoj-Inspiron-3542>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Date: Wed, 17 Feb 2016 20:33:26 +0530

> Failure of kzalloc should cause the enclosing function
> to return -ENOMEM, not -ENODEV.
> 
> Additionally, removed the following checkpatch warnings:
> ERROR: spaces required around that '==' (ctx:VxV)
> ERROR: space required before the open parenthesis '('
> CHECK: Comparison to NULL could be written "!lp"
> 
> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>

Applied, thanks.
