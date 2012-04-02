From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/8] net/ipv6/datagram.c: Checkpatch cleanups
Date: Sun, 01 Apr 2012 23:07:19 -0400 (EDT)
Message-ID: <20120401.230719.1756566896429508175.davem@davemloft.net>
References: <1333302548-9187-1-git-send-email-eldad@fogrefinery.com>
	<1333302548-9187-3-git-send-email-eldad@fogrefinery.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eldad@fogrefinery.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1333302548-9187-3-git-send-email-eldad@fogrefinery.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eldad Zack <eldad@fogrefinery.com>
Date: Sun,  1 Apr 2012 19:49:03 +0200

> datagram.c:101: ERROR: "(foo*)" should be "(foo *)"
> datagram.c:521: ERROR: space required before the open parenthesis '('
> datagram.c:830: WARNING: braces {} are not necessary for single statement blocks
> datagram.c:849: WARNING: braces {} are not necessary for single statement blocks
> 
> Signed-off-by: Eldad Zack <eldad@fogrefinery.com>

Applied.
