From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net 0/2] net_sched: bug fixes for ife action
Date: Thu, 23 Jun 2016 12:02:50 -0400 (EDT)
Message-ID: <20160623.120250.2202585199764678985.davem@davemloft.net>
References: <1466455039-23268-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, khoroshilov@ispras.ru
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33342 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbcFWQC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 12:02:56 -0400
In-Reply-To: <1466455039-23268-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 20 Jun 2016 13:37:17 -0700

> Cong Wang (2):
>   act_ife: only acquire tcf_lock for existing actions
>   act_ife: acquire ife_mod_lock before reading ifeoplist

Series applied, thanks.
