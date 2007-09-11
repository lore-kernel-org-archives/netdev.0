From: David Miller <davem@davemloft.net>
Subject: Re: [INET_DIAG]: Fix oops in netlink_rcv_skb
Date: Tue, 11 Sep 2007 02:34:11 -0700 (PDT)
Message-ID: <20070911.023411.59654776.davem@davemloft.net>
References: <46E4F761.4050902@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org, link@miggy.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:33402
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753887AbXIKJe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2007 05:34:26 -0400
In-Reply-To: <46E4F761.4050902@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 10 Sep 2007 09:50:57 +0200

> Fix the oidentd oops reported by Athanasius <link@miggy.org> in
> http://bugzilla.kernel.org/show_bug.cgi?id=8961
> 
> The oops is a 2.6.22 regression and triggerable by normal users.
> The patch applies cleanly to current -git and stable-2.6.22.

Applied, thanks Patrick.
