From: Denys Fedorysychenko <nuclearcat@nuclearcat.com>
Subject: Re: [RFC] ppp: Bridge Control Protocol
Date: Wed, 3 Mar 2010 10:45:37 +0200
Message-ID: <201003031045.37252.nuclearcat@nuclearcat.com>
References: <20100301145915.2ecaac89@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David@mail.vyatta.com, David Miller <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	bridge@linux-foundation.org, netdev@vger.kernel.org,
	dane@aiinet.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20100301145915.2ecaac89@nehalam>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 02 March 2010 00:59:15 Stephen Hemminger wrote:
> This is a port of an old patch to provide BCP support.
> BCP allows bridging PPP tunnels, it useful to do bridging between
> virtualized environments. Original patch was done by
> Dan Eble but was for 2.4.21.
Mikrotik has, when pppd patch will be ready - i can try to test.

P.S. They are also based on Linux, but i guess they have their own version of 
patch.

