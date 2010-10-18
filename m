From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH resend] netfilter: fix kconfig unmet dependency warning
Date: Mon, 18 Oct 2010 11:14:28 +0200
Message-ID: <4CBC0FF4.2020503@trash.net>
References: <20101016191103.ba9b2e7e.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, davem@davemloft.net,
	netfilter-devel@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101016191103.ba9b2e7e.randy.dunlap@oracle.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 17.10.2010 04:11, schrieb Randy Dunlap:
> Fix netfilter kconfig unmet dependencies warning & spell out
> "compatible" while there.
> 
> warning: (IP_NF_TARGET_TTL && NET && INET && NETFILTER && IP_NF_IPTABLES && NETFILTER_ADVANCED || IP6_NF_TARGET_HL && NET && INET && IPV6 && NETFILTER && IP6_NF_IPTABLES && NETFILTER_ADVANCED) selects NETFILTER_XT_TARGET_HL which has unmet direct dependencies ((IP_NF_MANGLE || IP6_NF_MANGLE) && NETFILTER_ADVANCED)


Applied, thanks.
