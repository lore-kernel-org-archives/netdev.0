From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/6] net/sock.h: make some fields private to fix
 kernel-doc warning(s)
Date: Sun, 09 Jan 2011 16:27:00 -0800 (PST)
Message-ID: <20110109.162700.52191043.davem@davemloft.net>
References: <20110108193921.e03ca09e.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	netdev@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110108193921.e03ca09e.randy.dunlap@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Sat, 8 Jan 2011 19:39:21 -0800

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Fix new kernel-doc notation warning in sock.h by annotating skc_dontcopy_*
> as private fields.
> 
> Warning(include/net/sock.h:163): No description found for parameter 'skc_dontcopy_end[0]'
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied.
