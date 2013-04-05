From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] net: ipv4: notify when address lifetime changes
Date: Fri, 05 Apr 2013 00:51:39 -0400 (EDT)
Message-ID: <20130405.005139.2189111135599404622.davem@davemloft.net>
References: <1365100380-6796-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53495 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130Ab3DEEvk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 00:51:40 -0400
In-Reply-To: <1365100380-6796-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  4 Apr 2013 20:33:00 +0200

> if userspace changes lifetime of address, send netlink notification and
> call notifier.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied and queued up for -stable, thanks Jiri.
