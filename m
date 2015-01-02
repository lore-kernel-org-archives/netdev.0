From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] MAINTAINERS: Update Open vSwitch entry.
Date: Fri, 02 Jan 2015 10:41:17 -0800
Message-ID: <1420224077.23591.2.camel@perches.com>
References: <1420223098-1591-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0042.hostedemail.com ([216.40.44.42]:36841 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752374AbbABSlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 13:41:22 -0500
In-Reply-To: <1420223098-1591-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-01-02 at 10:24 -0800, Pravin B Shelar wrote:
> OVS development is moved to netdev mailing list. Update tree and
> list in MAINTAINERS file.
[]
> diff --git a/MAINTAINERS b/MAINTAINERS
[]
> @@ -7008,9 +7008,11 @@ F:	arch/openrisc/
>  
>  OPENVSWITCH
>  M:	Pravin Shelar <pshelar@nicira.com>
> +L:	netdev@vger.kernel.org
>  L:	dev@openvswitch.org
>  W:	http://openvswitch.org
> -T:	git git://git.kernel.org/pub/scm/linux/kernel/git/pshelar/openvswitch.git
> +T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git
> +T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
>  S:	Maintained
>  F:	net/openvswitch/
>  

Are those git entries really appropriate?
