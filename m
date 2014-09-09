From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] netfilter: create audit records for ebtables
 replaces
Date: Tue, 9 Sep 2014 12:11:48 +0200
Message-ID: <20140909101148.GA12123@salvia>
References: <20140907160728.GA4589@salvia>
 <1410178305-28800-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu,
	stephen@networkplumber.org, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-audit@redhat.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40172 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752215AbaIIKKy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2014 06:10:54 -0400
Content-Disposition: inline
In-Reply-To: <1410178305-28800-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 08, 2014 at 02:11:45PM +0200, Nicolas Dichtel wrote:
> This is already done for x_tables (family AF_INET and AF_INET6), let's do it
> for AF_BRIDGE also.

Applied, thanks Nicolas.
