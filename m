From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7 net-next 00/16] ipv6: Enable GUEoIPv6 and more fixes
 for v6 tunneling
Date: Fri, 20 May 2016 18:03:46 -0400 (EDT)
Message-ID: <20160520.180346.718819364943098831.davem@davemloft.net>
References: <1463587584-2315623-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52994 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbcETWDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 18:03:48 -0400
In-Reply-To: <1463587584-2315623-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Wed, 18 May 2016 09:06:08 -0700

> This patch set:
>   - Fixes GRE6 to process translate flags correctly from configuration
>   - Adds support for GSO and GRO for ip6ip6 and ip4ip6
>   - Add support for FOU and GUE in IPv6
>   - Support GRE, ip6ip6 and ip4ip6 over FOU/GUE
>   - Fixes ip6_input to deal with UDP encapsulations
>   - Some other minor fixes

Series applied, thanks Tom.
