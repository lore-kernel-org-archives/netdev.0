From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: remove forward module param confusion.
Date: Thu, 22 Mar 2012 22:36:41 -0400 (EDT)
Message-ID: <20120322.223641.2119502285314364845.davem@davemloft.net>
References: <20120322182623.GA29859@elgon.mountain>
	<8762dw9to2.fsf@rustcorp.com.au>
	<8739909sqt.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <8739909sqt.fsf@rustcorp.com.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Fri, 23 Mar 2012 08:57:06 +1030

> It used to be an int, and it got changed to a bool parameter at least
> 7 years ago.  It happens that NF_ACCEPT and NF_DROP are 0 and 1, so
> this works, but it's unclear, and the check that it's in range is not
> required.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Applied.
