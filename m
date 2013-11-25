From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: netfilter: ipset: fix incorret comparison in
 hash_netnet4_data_equal()
Date: Mon, 25 Nov 2013 22:45:11 +0100
Message-ID: <20131125214511.GA10043@localhost>
References: <20131114154101.GA22625@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa,
	netfilter-devel@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54331 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752722Ab3KYVpU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Nov 2013 16:45:20 -0500
Content-Disposition: inline
In-Reply-To: <20131114154101.GA22625@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 14, 2013 at 10:41:01AM -0500, Dave Jones wrote:
> Both sides of the comparison are the same, looks like a cut-and-paste error.
> 
> Spotted by Coverity.

Applied, thanks Dave.

Please, cc netfilter-devel for netfilter patches next time.
