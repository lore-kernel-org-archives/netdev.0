From: jamal <hadi@cyberus.ca>
Subject: Re: Hard freeze with 2.6.10-rc3 and QoS, worked fine with 2.6.9
Date: 08 Dec 2004 07:04:30 -0500
Message-ID: <1102507470.1051.27.camel@jzny.localdomain>
References: <1102380430.6103.6.camel@buffy>
	 <20041206224441.628e7885.akpm@osdl.org>
	 <1102422544.1088.98.camel@jzny.localdomain> <41B5E188.5050800@trash.net>
	 <20041207170748.GF1371@postel.suug.ch> <41B5E722.2080600@trash.net>
	 <20041207213053.6bb602c1.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, tgraf@suug.ch, akpm@osdl.org,
	tomc@compaqnet.fr, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261191AbULHMEi@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041207213053.6bb602c1.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



I can almost guarantee that one or more of those tests i outlined would
fail. So i would suggest a revert until the testing has been done.

cheers,
jamal

On Wed, 2004-12-08 at 00:30, David S. Miller wrote:
> On Tue, 07 Dec 2004 18:23:46 +0100
> Patrick McHardy <kaber@trash.net> wrote:
> 
> > Either one is fine with me, although I would prefer to see
> > the number of ifdefs in this area going down, not up :)
> 
> I agree, therefore I applied Patrick's patch.
> 
