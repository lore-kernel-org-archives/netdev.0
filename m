From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: make tcp_clear_md5_list static
Date: Wed, 31 Oct 2012 14:05:06 -0400 (EDT)
Message-ID: <20121031.140506.2164048477828059527.davem@davemloft.net>
References: <20121026173140.54fb1f6f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47959 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935727Ab2JaSFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 14:05:09 -0400
In-Reply-To: <20121026173140.54fb1f6f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 26 Oct 2012 17:31:40 -0700

> Trivial. Only used in one file.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
