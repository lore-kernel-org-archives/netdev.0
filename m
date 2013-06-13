From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] net: make all team port device link events
 urgent
Date: Thu, 13 Jun 2013 02:32:07 -0700 (PDT)
Message-ID: <20130613.023207.1163522005017879178.davem@davemloft.net>
References: <1370984969-15797-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, fbl@redhat.com,
	bhutchings@solarflare.com, tj@kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38376 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757284Ab3FMJcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 05:32:08 -0400
In-Reply-To: <1370984969-15797-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 11 Jun 2013 23:09:29 +0200

> From: Flavio Leitner <fbl@redhat.com>
> 
> Since team functionality relies heavily on userspace daemon, we need to
> deliver event to userspace via Netlink as quick as possible. So make all
> team port device link events urgent.
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied, thanks.
