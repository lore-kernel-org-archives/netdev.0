From: "David S. Miller" <davem@davemloft.net>
Subject: Re: patch: annoying u32 double listing
Date: Sun, 6 Feb 2005 22:36:46 -0800
Message-ID: <20050206223646.239c0d77.davem@davemloft.net>
References: <1107719343.1055.22.camel@jzny.localdomain>
	<42068EA2.6030507@trash.net>
	<1107727330.1053.44.camel@jzny.localdomain>
	<4206A58A.9050909@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4206A58A.9050909@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 07 Feb 2005 00:17:30 +0100
Patrick McHardy <kaber@trash.net> wrote:

> jamal wrote:
> 
> >I should have caught that output missing divisor ;->
> >Dave please apply Patricks version. Should probably apply cleanly on
> >2.4.x as well.
> >
> My last patch has a similar problem, new hash tables added with
> "u32 divisor .." are skipped while walking. This patch is better
> tested and should be fine. Applies to 2.4 and 2.6.

After seeing 4+ revisions of the same bug fix on the same day,
let's let this sink for another day to make sure it's really
the final version :-)
