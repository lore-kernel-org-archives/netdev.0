From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: unlock in error path
Date: Fri, 19 Feb 2016 15:40:25 -0500 (EST)
Message-ID: <20160219.154025.1131784731536194813.davem@davemloft.net>
References: <1455727655-32106-1-git-send-email-wuninsu@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, ying.xue@windriver.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, taesoo@gatech.edu,
	yeongjin.jang@gatech.edu, insu@gatech.edu, changwoo@gatech.edu
To: wuninsu@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38005 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992835AbcBSUk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 15:40:28 -0500
In-Reply-To: <1455727655-32106-1-git-send-email-wuninsu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Insu Yun <wuninsu@gmail.com>
Date: Wed, 17 Feb 2016 11:47:35 -0500

> tipc_bcast_unlock need to be unlocked in error path.
> 
> Signed-off-by: Insu Yun <wuninsu@gmail.com>

Applied.
