From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 2/2] team: avoid using variable-length array
Date: Fri, 18 Nov 2011 15:00:20 -0500 (EST)
Message-ID: <20111118.150020.1817609880673347945.davem@davemloft.net>
References: <1321539365-1125-1-git-send-email-jpirko@redhat.com>
	<1321539365-1125-2-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	andy@greyhouse.net, fbl@redhat.com, jzupka@redhat.com,
	ivecera@redhat.com, mirqus@gmail.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34764 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212Ab1KRUA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 15:00:26 -0500
In-Reply-To: <1321539365-1125-2-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Thu, 17 Nov 2011 15:16:05 +0100

> Apparently using variable-length array is not correct
> (https://lkml.org/lkml/2011/10/23/25). So remove it.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied.
