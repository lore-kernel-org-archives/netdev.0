From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Hard freeze with 2.6.10-rc3 and QoS, worked fine with 2.6.9
Date: Tue, 7 Dec 2004 21:30:53 -0800
Message-ID: <20041207213053.6bb602c1.davem@davemloft.net>
References: <1102380430.6103.6.camel@buffy>
	<20041206224441.628e7885.akpm@osdl.org>
	<1102422544.1088.98.camel@jzny.localdomain>
	<41B5E188.5050800@trash.net>
	<20041207170748.GF1371@postel.suug.ch>
	<41B5E722.2080600@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, hadi@cyberus.ca, akpm@osdl.org, tomc@compaqnet.fr,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41B5E722.2080600@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 07 Dec 2004 18:23:46 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Either one is fine with me, although I would prefer to see
> the number of ifdefs in this area going down, not up :)

I agree, therefore I applied Patrick's patch.
