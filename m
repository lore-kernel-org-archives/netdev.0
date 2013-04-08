From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] tcp: add a global sysctl to control TCP
 delayed ack
Date: Mon, 08 Apr 2013 09:45:41 +0800
Message-ID: <1365385541.31063.0.camel@cr0>
References: <1365070560-11544-1-git-send-email-amwang@redhat.com>
	 <20130407.170958.338519719729552895.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, rick.jones2@hp.com,
	shemminger@vyatta.com, tgraf@suug.ch, David.Laight@ACULAB.COM
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62785 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934665Ab3DHBqI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Apr 2013 21:46:08 -0400
In-Reply-To: <20130407.170958.338519719729552895.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-04-07 at 17:09 -0400, David Miller wrote:
> 
> I'm not applying a patch that adds a global parameter for
> an attribute which has per-path scope.

Ok, I will make it per-route.

Thanks.
