From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IB/ipoib: Bound the net device to the ipoib_neigh
 structue
Date: Tue, 09 Oct 2007 18:12:46 -0700 (PDT)
Message-ID: <20071009.181246.41634534.davem@davemloft.net>
References: <11916151232222-git-send-email-fubar@us.ibm.com>
	<470C200D.4010705@pobox.com>
	<470C2343.1020800@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, monis@voltaire.com, ogerlitz@voltaire.com,
	netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60132
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753316AbXJJBNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 21:13:00 -0400
In-Reply-To: <470C2343.1020800@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Tue, 09 Oct 2007 20:56:35 -0400

> Jeff Garzik wrote:
> > applied patches 1-9
> > 
> > the only thing that was a hiccup during submission is that your email 
> > subject lines did not contain a notion of ordering "[PATCH 1/9] ...". 
> > But other than that, the git-send-email went flawlessly.
> 
> unfortunately it does not seem to build flawlessly:

Yeah it doesn't handle Stephen Hemmingers headerops change
in net-2.6.24

