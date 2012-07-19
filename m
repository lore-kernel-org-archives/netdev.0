From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: optimize fib_compute_spec_dst call in
 ip_options_echo
Date: Thu, 19 Jul 2012 08:30:59 -0700 (PDT)
Message-ID: <20120719.083059.1817508837752237594.davem@davemloft.net>
References: <1342683264-3523-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45216 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031Ab2GSPbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 11:31:00 -0400
In-Reply-To: <1342683264-3523-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Thu, 19 Jul 2012 10:34:24 +0300

> 	Move fib_compute_spec_dst at the only place where it
> is needed.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied.
