From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] DCCP: fix printk format warnings
Date: Sun, 29 Oct 2006 16:04:02 -0800 (PST)
Message-ID: <20061029.160402.92581862.davem@davemloft.net>
References: <20061029132440.4bb93676.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@mandriva.com, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:3239
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030454AbWJ3AEM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Oct 2006 19:04:12 -0500
To: randy.dunlap@oracle.com
In-Reply-To: <20061029132440.4bb93676.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Sun, 29 Oct 2006 13:24:40 -0800

> Fix printk format warnings:
> build2.out:net/dccp/ccids/ccid2.c:355: warning: long long unsigned int format, u64 arg (arg 3)
> build2.out:net/dccp/ccids/ccid2.c:360: warning: long long unsigned int format, u64 arg (arg 3)
> build2.out:net/dccp/ccids/ccid2.c:482: warning: long long unsigned int format, u64 arg (arg 5)
> build2.out:net/dccp/ccids/ccid2.c:639: warning: long long unsigned int format, u64 arg (arg 3)
> build2.out:net/dccp/ccids/ccid2.c:639: warning: long long unsigned int format, u64 arg (arg 4)
> build2.out:net/dccp/ccids/ccid2.c:674: warning: long long unsigned int format, u64 arg (arg 3)
> build2.out:net/dccp/ccids/ccid2.c:720: warning: long long unsigned int format, u64 arg (arg 3)
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks a lot Randy.
