From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next] drivers/net: add 6WIND SHULTI support
Date: Wed, 27 Apr 2016 11:56:15 +0200
Message-ID: <20160427095615.GA27071@breakpoint.cc>
References: <1461749838-4613-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, jiri@resnulli.us
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:37849 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752550AbcD0J4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 05:56:20 -0400
Content-Disposition: inline
In-Reply-To: <1461749838-4613-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
> This patch adds the support of the 6WIND SHULTI switch. It is a software
> switch doing L2 forwarding.
> 
> This first version implements the minimum needed to get the device working.
> It also implements, via switchdev and rtnetlink, bridge forwarding offload,
> including FDB static entries, FDB learning and FDB ageing.

How is this different from net/bridge?
How is this different from openvswitch?
