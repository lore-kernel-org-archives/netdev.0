From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next 1/2] ping: some cleanup for net/ipv4/ping.c
Date: Mon, 03 Jun 2013 14:05:28 +0800
Message-ID: <1370239528.32297.2.camel@cr0>
References: <1370238959-32008-1-git-send-email-amwang@redhat.com>
	 <1370239147.2025.0.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Lorenzo Colitti <lorenzo@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7530 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752138Ab3FCGFk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 02:05:40 -0400
In-Reply-To: <1370239147.2025.0.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-06-02 at 22:59 -0700, Joe Perches wrote:
> 
> why does this matter?
> 
> 

It is not a problem at all, I just want to make it clear that %pI6c
accepts struct in6_addr *.

BTW, $subject already says this patch is a pure cleanup.
