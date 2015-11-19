From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 00/14] net: extend busy polling support
Date: Thu, 19 Nov 2015 08:53:52 -0800
Message-ID: <1447952032.22599.231.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447857063-618-1-git-send-email-edumazet@google.com>
	 <20151118.161826.1686345343654337694.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org,
	eliezer.tamir@linux.intel.com, eli@mellanox.com,
	eugenia@mellanox.com, ariel.elior@qlogic.com, willemb@google.com,
	rida@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35885 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758685AbbKSQxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 11:53:54 -0500
Received: by pacdm15 with SMTP id dm15so86260942pac.3
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 08:53:54 -0800 (PST)
In-Reply-To: <20151118.161826.1686345343654337694.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-18 at 16:18 -0500, David Miller wrote:
> ers (by disabling busy polling on them)
> > or revert this last patch.
> 
> I like this series a lot, and hope we can fix any fallout quickly and
> painlessly.
> 
> Applied to net-next.

Thanks David. Could you push your tree so that we can start the testing
phase on more drivers ?

Thanks !
