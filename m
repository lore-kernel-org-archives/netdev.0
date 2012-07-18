From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] net-tcp: Fast Open base
Date: Wed, 18 Jul 2012 13:18:00 -0700 (PDT)
Message-ID: <20120718.131800.1584742811449253752.davem@davemloft.net>
References: <1342473410-6265-2-git-send-email-ycheng@google.com>
	<20120716.231644.1189536600250332545.davem@davemloft.net>
	<1342641349.2626.3555.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, hkchu@google.com, edumazet@google.com,
	ncardwell@google.com, sivasankar@cs.ucsd.edu,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37887 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753204Ab2GRUSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 16:18:03 -0400
In-Reply-To: <1342641349.2626.3555.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Jul 2012 21:55:49 +0200

> So the plan would be :
> 
> 1) Use the experimental 254 + magic on TFO Clients/Servers in 2012
> 
> 2) When/If IANA grants an official number, add its support to servers
>    (keeping support for experimental option as well)
> 
> 3) One/two years later, switch client side to use this official number
> 
> 4) Ten years later, remove experimental from server side.

Fair enough.
