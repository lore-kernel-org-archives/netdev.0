From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bonding: reset the slave's mtu when its be changed
Date: Fri, 10 Jan 2014 13:33:53 -0500 (EST)
Message-ID: <20140110.133353.594795064659135225.davem@davemloft.net>
References: <52CFDA63.8070601@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41640 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209AbaAJSdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 13:33:55 -0500
In-Reply-To: <52CFDA63.8070601@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Fri, 10 Jan 2014 19:32:51 +0800

> All slave should have the same mtu with mastet's, and the bond do it when
                                          ^^^^^^

Typo, you mean "master"
