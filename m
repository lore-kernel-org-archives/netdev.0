From: "David S. Miller" <davem@redhat.com>
Subject: Re: changing MTU on b44 breaks eth0
Date: Mon, 3 Nov 2003 15:16:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031103151618.79704b30.davem@redhat.com>
References: <1067888106.3366.20.camel@bluez.bueche.ch>
	<20031103205335.GA7668@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: charles@bueche.ch, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Pietikainen <pp@ee.oulu.fi>
In-Reply-To: <20031103205335.GA7668@ee.oulu.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 3 Nov 2003 22:53:35 +0200
Pekka Pietikainen <pp@ee.oulu.fi> wrote:

> Anyway, here's a (untested) patch that should fix the problem. As a bonus I
> even snuck in a new feature, power management support! 

I think Jeff should merge this upstrea, but I really disagree
with the CONFIG_PM ifdefs for the power-management support.
