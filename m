From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 5/13 net-2.6.26] [SCTP]: Use inet_ctl_sock_create for
	control socket creation.
Date: Mon, 31 Mar 2008 10:46:32 -0300
Message-ID: <20080331134631.GG14945@ghostprotocols.net>
References: <1206969367.10660.16.camel@iris.sw.ru> <1206969413-12096-5-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	containers@lists.osdl.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54817 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750825AbYCaNrH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 09:47:07 -0400
Content-Disposition: inline
In-Reply-To: <1206969413-12096-5-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, Mar 31, 2008 at 05:16:45PM +0400, Denis V. Lunev escreveu:
> sk->sk_proc->(un)hash is noop right now, so the unification is correct.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
