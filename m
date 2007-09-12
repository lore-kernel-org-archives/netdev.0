From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] make sctp_addto_param() static
Date: Wed, 12 Sep 2007 06:17:06 -0700 (PDT)
Message-ID: <20070912.061706.15251290.davem@davemloft.net>
References: <20070909202550.GX3563@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yjwei@cn.fujitsu.com, vladislav.yasevich@hp.com, sri@us.ibm.com,
	linux-kernel@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:35975
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755962AbXILNR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 09:17:27 -0400
In-Reply-To: <20070909202550.GX3563@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@kernel.org>
Date: Sun, 9 Sep 2007 22:25:50 +0200

> sctp_addto_param() can become static.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Applied, thanks.
