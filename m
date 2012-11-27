From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC PATCH 1/2] bridge: export port_no and port_id via
 IFA_INFO_DATA
Date: Tue, 27 Nov 2012 12:00:15 +0000
Message-ID: <20121127120015.GB16701@casper.infradead.org>
References: <1354009785-20014-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41474 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753443Ab2K0MAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 07:00:17 -0500
Content-Disposition: inline
In-Reply-To: <1354009785-20014-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/27/12 at 05:49pm, Cong Wang wrote:
> Based on net-next.
> 
> This patch exports port->port_no port->port_id in the end of IFA_INFO_DATA.
> 
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Thomas Graf <tgraf@suug.ch>
> Cc: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
