From: "David S. Miller" <davem@redhat.com>
Subject: Re: SCTP sockopt discrepancy between 2.4 and 2.6.
Date: Mon, 2 Feb 2004 11:21:50 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040202112150.3c8d5218.davem@redhat.com>
References: <1075747382.786.366.camel@hades.cambridge.redhat.com>
	<Pine.LNX.4.58.0402021056290.2352@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, netdev@oss.sgi.com, marcelo.tosatti@cyclades.com,
        lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0402021056290.2352@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I appreciate your status report Sridhar, thank you.

But the fact of the matter is that 2.4.x and 2.6.x cannot export two
totally incompatible user visible APIs for the SCTP socket layer.

This is something which must be fixed, not something we would like to
be fixed :-)
