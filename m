From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] net: add busy_poll device feature
Date: Thu, 03 Apr 2014 14:32:07 -0400 (EDT)
Message-ID: <20140403.143207.484902230429083643.davem@davemloft.net>
References: <1396472971-1450-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, edumazet@google.com,
	vyasevic@redhat.com, horms@verge.net.au, vfalico@redhat.com,
	nicolas.dichtel@6wind.com, ebiederm@xmission.com,
	stephen@networkplumber.org, hkchu@google.com, yanb@mellanox.com,
	john.r.fastabend@intel.com, dragos.foianu@gmail.com, bjorn@mork.no,
	mschmidt@redhat.com, fernando_b1@lab.ntt.co.jp, ben@decadent.org.uk
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46064 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753186AbaDCSag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 14:30:36 -0400
In-Reply-To: <1396472971-1450-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed,  2 Apr 2014 23:09:31 +0200

> Currently there is no way how to find out if a device supports busy
> polling. So add a feature and make it dependent on ndo_busy_poll
> existence.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Looks reasonable, applied, thanks Jiri.
