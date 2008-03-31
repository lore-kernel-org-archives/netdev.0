From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 9/13 net-2.6.26] [ICMP]: Simplify ICMP control socket
	creation.
Date: Mon, 31 Mar 2008 10:51:55 -0300
Message-ID: <20080331135155.GK14945@ghostprotocols.net>
References: <1206969367.10660.16.camel@iris.sw.ru> <1206969413-12096-9-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	containers@lists.osdl.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34767 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751130AbYCaNw2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 09:52:28 -0400
Content-Disposition: inline
In-Reply-To: <1206969413-12096-9-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, Mar 31, 2008 at 05:16:49PM +0400, Denis V. Lunev escreveu:
> Replace sock_create_kern with inet_ctl_sock_create.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

This one is perfect


Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
