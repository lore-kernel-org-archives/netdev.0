From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] packet: fix using smp_processor_id() in
 preemptible code
Date: Thu, 12 Dec 2013 16:15:23 -0500 (EST)
Message-ID: <20131212.161523.1172258207723966525.davem@davemloft.net>
References: <1386828604.2584.13.camel@ThinkPad-T5421>
	<52A83699.9010504@redhat.com>
	<1386888664.2586.3.camel@ThinkPad-T5421>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org, brouer@redhat.com
To: zhong@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39817 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751527Ab3LLVPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 16:15:25 -0500
In-Reply-To: <1386888664.2586.3.camel@ThinkPad-T5421>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Zhong <zhong@linux.vnet.ibm.com>
Date: Fri, 13 Dec 2013 06:51:04 +0800

Please fix the date on your computer.
