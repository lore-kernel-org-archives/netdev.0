From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: fix netjet/isdnhdlc build errors
Date: Mon, 28 Sep 2009 12:47:58 -0700 (PDT)
Message-ID: <20090928.124758.05417667.davem@davemloft.net>
References: <alpine.LFD.2.01.0909271511190.3349@localhost.localdomain>
	<20090928092520.b6f921de.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org,
	keil@b1-systems.de, netdev@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753115AbZI1Trk@vger.kernel.org>
In-Reply-To: <20090928092520.b6f921de.randy.dunlap@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Mon, 28 Sep 2009 09:25:20 -0700

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Commit cb3824bade2549d7ad059d5802da43312540fdee didn't fix this problem.
> 
> Fix build errors in netjet, using isdnhdlc module:
...
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Since Karsten has been unresonspive to ISDN stuff for weeks,
I'm going to apply this directly.

Thanks!
