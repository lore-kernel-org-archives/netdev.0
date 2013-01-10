From: David Miller <davem@davemloft.net>
Subject: Re: [patch] bnx2x: NULL dereference on error in debug code
Date: Wed, 09 Jan 2013 23:53:49 -0800 (PST)
Message-ID: <20130109.235349.2198186690882677527.davem@davemloft.net>
References: <20130108134213.GA23742@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130108134213.GA23742@elgon.mountain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 8 Jan 2013 16:42:14 +0300

> "vfop" is NULL here.  I've changed the debugging to not use it.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
