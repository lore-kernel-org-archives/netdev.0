From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] virtio_net: remove unused parameter to
 send_command
Date: Tue, 10 Dec 2013 22:28:33 -0500 (EST)
Message-ID: <20131210.222833.203879336646691401.davem@davemloft.net>
References: <20131209161632.5ac96e5a@nehalam.linuxnetplumber.net>
	<20131209161740.5f2cfae7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, mst@redhat.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54057 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751921Ab3LKD2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 22:28:35 -0500
In-Reply-To: <20131209161740.5f2cfae7@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 9 Dec 2013 16:17:40 -0800

> All the code passes NULL for the last sg list (in).
> Simplify by just removing it.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
