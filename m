From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add encap_rcv support to IPv6
Date: Wed, 21 Mar 2012 22:14:01 -0400 (EDT)
Message-ID: <20120321.221401.888858219757094388.davem@davemloft.net>
References: <20120320135855.GB30155@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48743 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756860Ab2CVCOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 22:14:04 -0400
In-Reply-To: <20120320135855.GB30155@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Tue, 20 Mar 2012 09:58:55 -0400

> At present, UDP encapsulated protocols (like L2TP) are only able to use the
> encap_rcv hook with UDP over IPv4.  This patch adds the same support for use
> with UDP over IPv6.
> 
> Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>

Sorry, this came in too late and will need to be resubmitted when the
net-next tree opens back up.
