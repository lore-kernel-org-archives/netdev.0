From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net 2/4] openvswitch: Clarify conntrack COMMIT
 behaviour
Date: Wed, 21 Oct 2015 19:34:13 -0700 (PDT)
Message-ID: <20151021.193413.2104715736442119623.davem@davemloft.net>
References: <1445307540-6786-1-git-send-email-joestringer@nicira.com>
	<1445307540-6786-2-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, tgraf@suug.ch,
	jrajahalme@nicira.com
To: joestringer@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49966 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755658AbbJVCRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 22:17:47 -0400
In-Reply-To: <1445307540-6786-2-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joestringer@nicira.com>
Date: Mon, 19 Oct 2015 19:18:58 -0700

> The presence of this attribute does not modify the ct_state for the
> current packet, only future packets. Make this more clear in the header
> definition.
> 
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Applied.
