From: Andi Kleen <ak@suse.de>
Subject: Re: Level One LXT1001 GE chip
Date: Fri, 28 Nov 2003 02:14:39 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031128021439.0f48de70.ak@suse.de>
References: <3FC3FB99.70700@wanadoo.es>
	<20031127010324.061cac3b.davem@redhat.com>
	<20031127122021.3ac80a86.ak@suse.de>
	<20031127122642.046d07ce.ak@suse.de>
	<1069941123.1027.6.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, xose@wanadoo.es, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1069941123.1027.6.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 27 Nov 2003 08:52:03 -0500
jamal <hadi@cyberus.ca> wrote:

> Andi, is this the driver you were playing those neat tricks with
> getting rid of some of the nastiness in eth_type_trans()?

Yep.

I didn't attempt to NAPIize it though. Also it is still somewhat buggy.

-Andi
