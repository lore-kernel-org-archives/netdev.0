From: jamal <hadi@cyberus.ca>
Subject: Re: dummy as IMQ replacement
Date: 31 Jan 2005 07:25:39 -0500
Message-ID: <1107174338.8021.123.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <200501311020.08337.hasso@estpak.ee>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Hasso Tepper <hasso@estpak.ee>
In-Reply-To: <200501311020.08337.hasso@estpak.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-01-31 at 03:20, Hasso Tepper wrote:
> Jamal Hadi Salim wrote:
> > 2) Allows for queueing incoming traffic for shaping instead of
> > dropping. I am not aware of any study that shows policing is
> > worse than shaping in achieving the end goal of rate control.
> > I would be interested if anyone is experimenting. Nevertheless,
> > this is still an alternative as opposed to making a system wide
> > ingress change.
> 
> Policing didn't work with IPv6 last time I checked.

Really? I take it this is using the u32 classifier?
What filter did you use?

cheers,
jamal
