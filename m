From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: dummy as IMQ replacement
Date: Mon, 31 Jan 2005 10:20:08 +0200
Message-ID: <200501311020.08337.hasso@estpak.ee>
References: <1107123123.8021.80.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@znyx.com
In-Reply-To: <1107123123.8021.80.camel@jzny.localdomain>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jamal Hadi Salim wrote:
> 2) Allows for queueing incoming traffic for shaping instead of
> dropping. I am not aware of any study that shows policing is
> worse than shaping in achieving the end goal of rate control.
> I would be interested if anyone is experimenting. Nevertheless,
> this is still an alternative as opposed to making a system wide
> ingress change.

Policing didn't work with IPv6 last time I checked.


-- 
Hasso Tepper
Elion Enterprises Ltd.
WAN administrator
