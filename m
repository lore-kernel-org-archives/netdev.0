From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/3] net sched action timestamp improvements
Date: Tue, 07 Jun 2016 15:54:05 -0700 (PDT)
Message-ID: <20160607.155405.778592531194331404.davem@davemloft.net>
References: <1465209175-8002-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	daniel@iogearbox.net
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58743 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932249AbcFGWyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 18:54:08 -0400
In-Reply-To: <1465209175-8002-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Mon,  6 Jun 2016 06:32:52 -0400

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> Various aggregations of duplicated code, fixes and introduction of firstused
> timestamp
> 
> v2: add const for source time info per suggestion from Cong

Series applied.
