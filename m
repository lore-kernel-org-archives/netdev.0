From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] sctp: Add Auto-ASCONF support
Date: Mon, 28 Mar 2011 16:18:57 -0700 (PDT)
Message-ID: <20110328.161857.193719177.davem@davemloft.net>
References: <D2DF7729-C887-443A-A159-EBE58120B4E2@sfc.wide.ad.jp>
	<4D901CE3.60501@cn.fujitsu.com>
	<6DE94EB5-FD33-4829-AE34-C14CFDD5E527@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yjwei@cn.fujitsu.com, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
To: micchie@sfc.wide.ad.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57682
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752975Ab1C1XTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 19:19:35 -0400
In-Reply-To: <6DE94EB5-FD33-4829-AE34-C14CFDD5E527@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michio Honda <micchie@sfc.wide.ad.jp>
Date: Tue, 29 Mar 2011 03:41:34 +0900

> Thanks for the comment, I implemented the setsockopt-based control,
> and ran the checkpatch.pl.  I attach the patch.

When posting a new version of a patch, post it as a completely
new posting so that the commit message and other elements are
understood by automated tools properly.
