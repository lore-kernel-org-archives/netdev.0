From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: make local function static
Date: Sun, 29 Dec 2013 16:38:51 -0500 (EST)
Message-ID: <20131229.163851.1617802806719335797.davem@davemloft.net>
References: <20131229114125.1db8d541@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48437 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752634Ab3L2Vix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Dec 2013 16:38:53 -0500
In-Reply-To: <20131229114125.1db8d541@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sun, 29 Dec 2013 11:41:25 -0800

> bond_xmit_slave_id is only used in main.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
