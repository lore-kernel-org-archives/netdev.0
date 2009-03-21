From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: Clean up TEST_FRAME hacks.
Date: Sat, 21 Mar 2009 13:41:16 -0700 (PDT)
Message-ID: <20090321.134116.52170180.davem@davemloft.net>
References: <49C2BC67.8030709@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56364
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754034AbZCUUl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 16:41:29 -0400
In-Reply-To: <49C2BC67.8030709@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Thu, 19 Mar 2009 17:43:03 -0400

> Remove 2 TEST_FRAME hacks that are no longer needed.  These allowed
> sctp regression tests to compile before, but are no longer needed.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
