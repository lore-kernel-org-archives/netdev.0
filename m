From: jamal <hadi@cyberus.ca>
Subject: Re: patch: annoying u32 double listing
Date: 06 Feb 2005 17:02:10 -0500
Message-ID: <1107727330.1053.44.camel@jzny.localdomain>
References: <1107719343.1055.22.camel@jzny.localdomain>
	 <42068EA2.6030507@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <42068EA2.6030507@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-02-06 at 16:39, Patrick McHardy wrote:
> jamal wrote:
> 
> >bug is around since 2.1.x; never cared about chasing it until now
> >because it is affecting someone i know.
> >Dave, please apply. I will prepare a 2.4.x version.
> >
> The patch is wrong. The "divisor"-lines are missing in the output with

I should have caught that output missing divisor ;->
Dave please apply Patricks version. Should probably apply cleanly on
2.4.x as well.

cheers,
jamal
