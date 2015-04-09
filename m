From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 2/2] tc: add 'needs_l2' flag to ingress
 qdisc
Date: Thu, 09 Apr 2015 01:25:11 -0400 (EDT)
Message-ID: <20150409.012511.1248862297693295711.davem@davemloft.net>
References: <20150408.231456.1063648455572594170.davem@davemloft.net>
	<5525F48F.5030108@plumgrid.com>
	<55260C2F.608@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, tgraf@suug.ch, jiri@resnulli.us,
	jhs@mojatatu.com, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44272 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751768AbbDIFZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 01:25:14 -0400
In-Reply-To: <55260C2F.608@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Wed, 08 Apr 2015 22:20:47 -0700

> so Dave, would you consider early_ingress_l2() hook that doesn't need
> to do skb_share_check ?

Let me think about it some more.
