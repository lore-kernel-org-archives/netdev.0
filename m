From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] rtnl_lock fixes
Date: Wed, 08 Jul 2015 16:15:33 -0700 (PDT)
Message-ID: <20150708.161533.531768243562810631.davem@davemloft.net>
References: <559BF5F8.2000500@virtuozzo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
To: vvs@virtuozzo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38372 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224AbbGHXPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 19:15:33 -0400
In-Reply-To: <559BF5F8.2000500@virtuozzo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasily Averin <vvs@virtuozzo.com>
Date: Tue, 07 Jul 2015 18:53:28 +0300

> While investigation possible reasons of net_todo_list corruption 
> on rhel6 based OpenVZ kernel I've found few places not fixed in mainline.

I'm assuming the Intel folks will pick these up.
