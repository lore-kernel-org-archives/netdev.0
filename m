From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch iproute2] add quickack option to ip route
Date: Wed, 19 Jun 2013 18:17:22 -0700
Message-ID: <20130619181722.50b2d7b7@nehalam.linuxnetplumber.net>
References: <1371260359-5875-1-git-send-email-amwang@redhat.com>
	<1371260359-5875-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:62826 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935191Ab3FTBR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 21:17:26 -0400
Received: by mail-pd0-f178.google.com with SMTP id w11so5673866pde.37
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 18:17:26 -0700 (PDT)
In-Reply-To: <1371260359-5875-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 15 Jun 2013 09:39:19 +0800
Cong Wang <amwang@redhat.com> wrote:

> From: Cong Wang <amwang@redhat.com>
> 
> This patch adds quickack option to enable/disable TCP quick ack
> mode for per-route.
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> 

I am still waiting until RTAX_QUICKACK is accepted into net-next to apply to net-next-3.10 branch
of iproute
