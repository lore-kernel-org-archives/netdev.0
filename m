From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: [PATCH] tcp: set congestion default through Kconfig
Date: Tue, 19 Sep 2006 17:08:49 +1200
Message-ID: <5640c7e00609182208t74aadacekcf0b588b7852464d@mail.gmail.com>
References: <20060918095936.GA6161@outpost.ds9a.nl>
	 <20060918.070600.107685035.davem@davemloft.net>
	 <20060918154048.GA18240@outpost.ds9a.nl>
	 <20060918.115309.88343320.davem@davemloft.net>
	 <20060918195224.GA26585@outpost.ds9a.nl>
	 <20060918214104.3824a2e2@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "bert hubert" <bert.hubert@netherlabs.nl>,
	"David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.131]:49884 "EHLO
	nf-out-f131.google.com") by vger.kernel.org with ESMTP
	id S1752059AbWISFIv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 01:08:51 -0400
Received: by nf-out-f131.google.com with SMTP id k65so496081nfa
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2006 22:08:49 -0700 (PDT)
To: "Stephen Hemminger" <shemminger@osdl.org>
In-Reply-To: <20060918214104.3824a2e2@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> ---
>  net/ipv4/Kconfig           |   39 +++++++++++++++++++++++++++++++++++++--
>  net/ipv4/sysctl_net_ipv4.c |    7 +++++++
>  net/ipv4/tcp_cong.c        |    2 +-
>  3 files changed, 45 insertions(+), 3 deletions(-)

Nice solution.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
