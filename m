From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/5] bonding: patchset for rcu use in
 bonding
Date: Mon, 28 Oct 2013 00:01:56 -0400 (EDT)
Message-ID: <20131028.000156.1066002649913193270.davem@davemloft.net>
References: <52688F33.30904@huawei.com>
	<20131027225317.GB11209@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dingtianhong@huawei.com, fubar@us.ibm.com, andy@greyhouse.net,
	nikolay@redhat.com, netdev@vger.kernel.org
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56094 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998Ab3J1EB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 00:01:58 -0400
In-Reply-To: <20131027225317.GB11209@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Sun, 27 Oct 2013 23:53:17 +0100

> This patch introduces a regression by boot-test with active backup
> mode:

Ok I'm reverting.
