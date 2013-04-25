From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] net: ipv4: typo issue, remove erroneous
 semicolon
Date: Thu, 25 Apr 2013 04:08:05 -0400 (EDT)
Message-ID: <20130425.040805.131739914219038988.davem@davemloft.net>
References: <5175F5C3.8060503@asianux.com>
	<20130423.011604.1061769362231812796.davem@davemloft.net>
	<51762E16.703@asianux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, pshelar@nicira.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org
To: gang.chen@asianux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49829 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755873Ab3DYIIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 04:08:07 -0400
In-Reply-To: <51762E16.703@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chen Gang <gang.chen@asianux.com>
Date: Tue, 23 Apr 2013 14:45:42 +0800

> Need remove erroneous semicolon, which is found by EXTRA_CFLAGS=-W,
> the related commit number: c54419321455631079c7d6e60bc732dd0c5914c5
> ("GRE: Refactor GRE tunneling code")
> 
> Signed-off-by: Chen Gang <gang.chen@asianux.com>

Applied.
