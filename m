From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH linux-next] nf_defrag_ipv6: fix oops on module unloading
Date: Wed, 26 Sep 2012 09:48:57 +0800
Message-ID: <1348624137.487.0.camel@cr0>
References: <20120925160750.30475.77562.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31318 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751299Ab2IZBtM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Sep 2012 21:49:12 -0400
In-Reply-To: <20120925160750.30475.77562.stgit@zurg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-09-25 at 20:07 +0400, Konstantin Khlebnikov wrote:
> fix copy-paste error introduced in linux-next commit
> "ipv6: add a new namespace for nf_conntrack_reasm"
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Cc: Amerigo Wang <amwang@redhat.com>
> Cc: David S. Miller <davem@davemloft.net>
> 

Oops! Sorry, my bad...

Acked-by: Cong Wang <amwang@redhat.com>
