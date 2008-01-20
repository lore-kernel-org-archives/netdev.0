From: David Miller <davem@davemloft.net>
Subject: Re: sctp use-uninitialized warning in net-2.6.25
Date: Sun, 20 Jan 2008 06:11:24 -0800 (PST)
Message-ID: <20080120.061124.46951088.davem@davemloft.net>
References: <47915DD4.7090109@hp.com>
	<20080118.203723.184002414.davem@davemloft.net>
	<479326B1.3090009@verizon.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: vyasevich@verizon.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54789
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752843AbYATOLU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 09:11:20 -0500
In-Reply-To: <479326B1.3090009@verizon.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@verizon.net>
Date: Sun, 20 Jan 2008 05:47:13 -0500

> Anyway, here is a patch that sets the correct value.

Applied, but I had to fix up the trailing whitespace on
line 29 of your patch. :-/

Thanks.
