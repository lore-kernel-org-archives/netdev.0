From: jamal <hadi@cyberus.ca>
Subject: Re: [1/2] CARP implementation. HA master's failover.
Date: 15 Jul 2004 12:28:20 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089908900.1027.77.camel@jzny.localdomain>
References: <1089898303.6114.859.camel@uganda>
	 <1089898595.6114.866.camel@uganda>
	 <1089902654.1029.23.camel@jzny.localdomain>
	 <1089905244.6114.887.camel@uganda>  <1089906936.6114.904.camel@uganda>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-failover@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <1089906936.6114.904.camel@uganda>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-07-15 at 11:55, Evgeniy Polyakov wrote:


> > OpenBSD's CARP does load balancing through Source Hashing (SH), which
> UCARP 
> > lacks support for.
> 
> Userspace can't in principle.
> Current kernel implementation can't too, but it can. In principle.

Easy with current traffic control extensions. We need an action written
for this. User space dameon controls it.

cheers,
jamal
