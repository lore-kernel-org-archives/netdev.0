From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net 0/3] ipv4: Fix ip-header identification for gso
 packets.
Date: Mon, 25 Mar 2013 11:48:15 +0800
Message-ID: <1364183295.2532.9.camel@cr0>
References: <1364182567-1667-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26112 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756840Ab3CYDs0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Mar 2013 23:48:26 -0400
In-Reply-To: <1364182567-1667-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-03-24 at 20:36 -0700, Pravin B Shelar wrote:
> Following patch fixes ip-header identification according to comments from
> David Miller and Cong Wang.
> First two patches reverts fixes to upper layer gso handlers which is not
> required after fixing ipv4 gso handler.
> 

Looks good to me now:

Acked-by: Cong Wang <amwang@redhat.com>

Thanks!
