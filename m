From: jamal <hadi@cyberus.ca>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: 12 Sep 2003 08:56:00 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1063371359.1027.99.camel@jzny.localdomain>
References: <200309022116.41697.bdschuym@pandora.be>
	 <20030903200426.59d0af4a.davem@redhat.com>
	 <20030905153152.GA3623@obroa-skai.de.gnumonks.org>
	 <1063330846.1028.11.camel@jzny.localdomain>
	 <20030912085606.GC2350@obroa-skai.de.gnumonks.org>
	 <Pine.LNX.4.53.0309121244400.2544@oskar-lap.agatha>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@netfilter.org>, "David S. Miller" <davem@redhat.com>,
   Bart De Schuymer <bdschuym@pandora.be>, acme@conectiva.com.br,
   netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Oskar Andreasson <blueflux@koffein.net>
In-Reply-To: <Pine.LNX.4.53.0309121244400.2544@oskar-lap.agatha>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2003-09-12 at 06:56, Oskar Andreasson wrote:

> Just to add my point o this, and to say that it is actually used in
> real-world. We have several (>30) machines with 120 modems each, each
> running a pppd (modem pool, yes), and some  300-400 iptables rules on each
> machine.
> 

How it is presented to the user - and how it is actually implemented are
two different things.
you could still enter it as ppp+ 

cheers,
jamal
