From: cliff white <cliffw@osdl.org>
Subject: Re: Ethtool doesn't work on Debian unstable?
Date: Thu, 10 Mar 2005 14:39:19 -0800
Message-ID: <20050310143919.27c7b9f2@es175>
References: <20050310135435.23af10b8@es175>
	<4230C703.6060706@tomt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
In-Reply-To: <4230C703.6060706@tomt.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 10 Mar 2005 23:15:31 +0100
Andre Tomt <andre@tomt.net> wrote:

> cliff white wrote:
> > This is wierd. I know I am doing something Real Stupid, but i can't figure it out.
> > 
> > Two systems.  2.6.11 kernel on both systems. 

[snip]

eration not supported)
> > 7657  dup(2)                            = 4
> > ------------------------
> > Can anyone help me here? I'd like to use Debian for this testing, but so far, no love.
> > cliffw
> > 
> > 
> 
> Most likely the other debian system just is using a network driver that 
> do not support ethtool, or even just that ethtool command. ethtool 
> support differs a lot between drivers, with quite a few not supporting 
> ethtool at all.
> 
Okay, my stupid. Had the wrong driver. Nothing to see here,move along
cliffw


-- 
"Ive always gone through periods where I bolt upright at four in the morning; 
now at least theres a reason." -Michael Feldman
