From: jamal <hadi@cyberus.ca>
Subject: Re: [1/2] CARP implementation. HA master's failover.
Date: 15 Jul 2004 10:44:14 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089902654.1029.23.camel@jzny.localdomain>
References: <1089898303.6114.859.camel@uganda>
	 <1089898595.6114.866.camel@uganda>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-failover@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <1089898595.6114.866.camel@uganda>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Evgeniy,

Why do you need to put this stuff in the kernel?
This should be implemented just the same way as VRRP was - in user
space.
BTW, is there a spec for this protocol or its one of those things where
you have to follow Yodas advice?

cheers,
jamal
