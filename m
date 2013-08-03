From: David Miller <davem@davemloft.net>
Subject: Re: [net] net_sched: make dev_trans_start return vlan's real dev
 trans_start
Date: Sat, 03 Aug 2013 12:37:08 -0700 (PDT)
Message-ID: <20130803.123708.246365101792191028.davem@davemloft.net>
References: <20130803.115228.1509916868029010372.davem@davemloft.net>
	<20130803190918.GA11976@redhat.com>
	<51FD5B78.6000208@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vfalico@redhat.com, netdev@vger.kernel.org, fubar@us.ibm.com,
	jhs@mojatatu.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52669 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752575Ab3HCThL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 15:37:11 -0400
In-Reply-To: <51FD5B78.6000208@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Sat, 03 Aug 2013 21:35:20 +0200

> Dave should I queue the patches (vlan change & net_sched's dev_trans_start)
> for net-next or net would be fine ?

I think these are bugs to 'net' is better.
