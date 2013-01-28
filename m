From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] pktgen: use the net namespace of current
 process instead of init_net
Date: Mon, 28 Jan 2013 11:13:14 +0800
Message-ID: <1359342794.20444.11.camel@cr0>
References: <1359340387-18004-1-git-send-email-amwang@redhat.com>
	 <87mwvu10rj.fsf@xmission.com> <1359341852.20444.10.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4381 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751380Ab3A1DNU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jan 2013 22:13:20 -0500
In-Reply-To: <1359341852.20444.10.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-28 at 10:57 +0800, Cong Wang wrote:
> 
> Hmm, I didn't think much about this. You are right... we could probably
> make these proc files per-net.

Cooking a patch now.
