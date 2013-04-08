From: David Miller <davem@davemloft.net>
Subject: Re: [patch net 0/2] net: ipv4: fix couple of addr lifetime related
 bugs
Date: Mon, 08 Apr 2013 12:05:30 -0400 (EDT)
Message-ID: <20130408.120530.642390905837222387.davem@davemloft.net>
References: <1365154779-4204-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49159 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582Ab3DHQFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 12:05:32 -0400
In-Reply-To: <1365154779-4204-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri,  5 Apr 2013 11:39:37 +0200

> Jiri Pirko (2):
>   net: ipv4: reset check_lifetime_work after changing lifetime
>   net: ipv4: fix schelude while atomic bug in check_lifetime()

Both applied, thanks Jiri.
