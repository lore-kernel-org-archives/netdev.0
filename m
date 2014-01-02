From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] stmicro: make local variables static
Date: Wed, 01 Jan 2014 23:44:13 -0500 (EST)
Message-ID: <20140101.234413.597442212756635211.davem@davemloft.net>
References: <20131230103857.00dee306@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46462 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774AbaABEoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 23:44:15 -0500
In-Reply-To: <20131230103857.00dee306@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 30 Dec 2013 10:38:57 -0800

> Make variables only used in one file static. Also avoids possible
> namespace collisions.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
