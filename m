From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/8] net/ipv6/exthdrs.c: Checkpatch cleanups
Date: Sun, 01 Apr 2012 23:07:25 -0400 (EDT)
Message-ID: <20120401.230725.2062070470189882316.davem@davemloft.net>
References: <1333302548-9187-1-git-send-email-eldad@fogrefinery.com>
	<1333302548-9187-4-git-send-email-eldad@fogrefinery.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eldad@fogrefinery.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1333302548-9187-4-git-send-email-eldad@fogrefinery.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eldad Zack <eldad@fogrefinery.com>
Date: Sun,  1 Apr 2012 19:49:04 +0200

> exthdrs.c:726: WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
> exthdrs.c:741: ERROR: "(foo*)" should be "(foo *)"
> exthdrs.c:741: ERROR: "(foo*)" should be "(foo *)"
> exthdrs.c:744: ERROR: "(foo**)" should be "(foo **)"
> exthdrs.c:746: ERROR: "(foo**)" should be "(foo **)"
> exthdrs.c:748: ERROR: "(foo**)" should be "(foo **)"
> exthdrs.c:750: ERROR: "(foo**)" should be "(foo **)"
> exthdrs.c:755: WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
> exthdrs.c:896: WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable
> 
> Signed-off-by: Eldad Zack <eldad@fogrefinery.com>

Applied.
