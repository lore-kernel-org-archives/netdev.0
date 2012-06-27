From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/3] team: couple of fixes
Date: Tue, 26 Jun 2012 21:09:14 -0700 (PDT)
Message-ID: <20120626.210914.240806774274535008.davem@davemloft.net>
References: <1340729567-3164-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, brouer@redhat.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38992 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714Ab2F0EJP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 00:09:15 -0400
In-Reply-To: <1340729567-3164-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Tue, 26 Jun 2012 18:52:44 +0200

> Jiri Pirko (3):
>   team: fix team_adjust_ops with regard to enabled ports
>   team: do not allow to map disabled ports
>   team: remove unuset rcu_head field from team_port struct

All looks good, I'll apply this, thanks Jiri.
