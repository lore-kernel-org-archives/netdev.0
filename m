From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: parse flag XFRM_POLICY_ICMP
Date: Tue, 12 Apr 2011 14:14:13 -0700
Message-ID: <20110412141413.104a4498@nehalam>
References: <20110407073705.GA6523@babylon>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ulrich Weber <uweber@astaro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47349 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932553Ab1DLVOS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 17:14:18 -0400
In-Reply-To: <20110407073705.GA6523@babylon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 7 Apr 2011 09:37:05 +0200
Ulrich Weber <uweber@astaro.com> wrote:

> parse flag XFRM_POLICY_ICMP
> 
> Signed-off-by: Ulrich Weber <uweber@astaro.com>
> ---
>  ip/ipxfrm.c      |    1 +
>  ip/xfrm_policy.c |    4 +++-
>  2 files changed, 4 insertions(+), 1 deletions(-)
> 

Applied to net-next branch

-- 
