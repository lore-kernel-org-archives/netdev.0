From: Roland Dreier <roland@topspin.com>
Subject: Re: [PATCH]: was Re: LLTX and netif_stop_queue
Date: Fri, 21 Jan 2005 19:17:07 -0800
Message-ID: <52is5qp2z0.fsf@topspin.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <iod00d@hp.com>, tommy.christensen@tpack.net,
        shemminger@osdl.org, hadi@cyberus.ca, eric.lemoine@gmail.com,
        netdev@oss.sgi.com, ak@suse.de, openib-general@openib.org,
        kaber@trash.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050120170113.36ee8225.davem@davemloft.net> (David S.
 Miller's message of "Thu, 20 Jan 2005 17:01:13 -0800")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

So what's the plan here with LLTX?  As far as I can tell, 2.6.11-rc2
went out with the changes that disable IRQs in hard_start_xmit...

 - R.
