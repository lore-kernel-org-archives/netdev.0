From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 3/3] team: replicate options on register
Date: Wed, 16 Nov 2011 20:36:30 -0500 (EST)
Message-ID: <20111116.203630.1648244435593843620.davem@davemloft.net>
References: <1321477749-1877-1-git-send-email-jpirko@redhat.com>
	<1321477749-1877-4-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	andy@greyhouse.net, fbl@redhat.com, jzupka@redhat.com,
	ivecera@redhat.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51867 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755212Ab1KQBgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 20:36:35 -0500
In-Reply-To: <1321477749-1877-4-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Wed, 16 Nov 2011 22:09:09 +0100

> Since multiple team instances are putting defined options into their
> option list, during register each option must be cloned before added
> into list. This resolves uncool memory corruptions when using multiple
> teams.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied.
