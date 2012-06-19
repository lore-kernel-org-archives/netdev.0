From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-next 2012-06-19
Date: Tue, 19 Jun 2012 14:38:38 -0700 (PDT)
Message-ID: <20120619.143838.2195312578230933662.davem@davemloft.net>
References: <20120619195757.GA7466@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58789 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752659Ab2FSVij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 17:38:39 -0400
In-Reply-To: <20120619195757.GA7466@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 19 Jun 2012 15:57:57 -0400

> This is a sizeable batch of updates intended for 3.6...
> 
> The bulk of the changes here are Bluetooth.  Gustavo says:
> 
> 	Here goes the first Bluetooth pull request for 3.6, we have
> 	queued quite a lot of work. Andrei Emeltchenko added the AMP
> 	Manager code, a lot of work is needed, but the first bit are
> 	already there. This code is disabled by default.  Mat Martineau
> 	changed the whole L2CAP ERTM state machine code, replacing
> 	the old one with a new implementation. Besides that we had
> 	lot of coding style fixes (to follow net rules), more l2cap
> 	core separation from socket and many clean ups and fixed all
> 	over the tree.
> 
> Along with the above, there is a healthy dose of ath9k, iwlwifi,
> and other driver updates.  There is also another pull from the
> wireless tree to resolve some merge issues.  I also fixed-up some
> merge discrepencies between net-next and wireless-next.
> 
> Please let me know if there are problems!

Pulled, thanks JOhn.
