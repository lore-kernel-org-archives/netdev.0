From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] SCTP: Initialize partial_bytes_acked to 0, when all of
 the data is acked.
Date: Thu, 17 Apr 2008 14:22:38 -0700 (PDT)
Message-ID: <20080417.142238.250302376.davem@davemloft.net>
References: <4805A2CA.7030808@cn.fujitsu.com>
	<4807B318.2000307@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: guijianfeng@cn.fujitsu.com, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net, linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50117
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752764AbYDQVWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 17:22:36 -0400
In-Reply-To: <4807B318.2000307@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Thu, 17 Apr 2008 16:29:12 -0400

> Loose the braces, otherwise looks good.

I took care of this an applied to net-2.6.26, thanks.
