From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH]: was Re: LLTX and netif_stop_queue
Date: Fri, 21 Jan 2005 19:53:56 -0800
Message-ID: <20050121195356.51cf3ade.davem@davemloft.net>
References: <5cac192f0501030907c755135@mail.gmail.com>
	<20050103171227.GD7370@esmail.cup.hp.com>
	<1104812294.1085.53.camel@jzny.localdomain>
	<20050119144711.3fdd3d93.davem@davemloft.net>
	<20050119151853.259de49a@dxpl.pdx.osdl.net>
	<20050119164640.6c67bdfa.davem@davemloft.net>
	<52r7kgu5n5.fsf@topspin.com>
	<20050119230526.393a5184.davem@davemloft.net>
	<1106229084.5812.40.camel@tsc-6.cph.tpack.net>
	<20050120133420.317bea31.davem@davemloft.net>
	<20050120215650.GB14521@esmail.cup.hp.com>
	<20050120170113.36ee8225.davem@davemloft.net>
	<52is5qp2z0.fsf@topspin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: iod00d@hp.com, tommy.christensen@tpack.net, shemminger@osdl.org,
        hadi@cyberus.ca, eric.lemoine@gmail.com, netdev@oss.sgi.com,
        ak@suse.de, openib-general@openib.org, kaber@trash.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Roland Dreier <roland@topspin.com>
In-Reply-To: <52is5qp2z0.fsf@topspin.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 21 Jan 2005 19:17:07 -0800
Roland Dreier <roland@topspin.com> wrote:

> So what's the plan here with LLTX?  As far as I can tell, 2.6.11-rc2
> went out with the changes that disable IRQs in hard_start_xmit...

Linus just didn't pull the backout of that stuff in time.
I'll repush it to him tonight.
