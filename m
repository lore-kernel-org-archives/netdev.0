From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3 v2] cnic fixes.
Date: Mon, 02 Jun 2014 23:17:22 -0700 (PDT)
Message-ID: <20140602.231722.1254992955908033401.davem@davemloft.net>
References: <1401775728-21043-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39613 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751732AbaFCGRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 02:17:23 -0400
In-Reply-To: <1401775728-21043-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <mchan@broadcom.com>
Date: Mon, 2 Jun 2014 23:08:45 -0700

> Fix 2 sleeping function from invalid context bugs and 1 missing iscsi netlink
> message bug.
> 
> v2: Fixed typo in rcu_dereference_protected() and tested with CONFIG_PROVE_RCU

Looks a lot better, series applied, thanks.
