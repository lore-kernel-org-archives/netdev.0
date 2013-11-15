From: Ian Kumlien <pomac@demius.net>
Subject: Re: [OOPS][3.12] BUG: unable to handle kernel NULL pointer
 dereference at 0000000c
Date: Sat, 16 Nov 2013 00:39:19 +0100
Message-ID: <20131115233919.GB11450@pomac.netswarm.net>
References: <20131115183422.GA9417@pomac.netswarm.net>
 <CAErSpo4jh7pO=jhZTvHD+sT2O12Ly6V3e_oiac8gHqmdmqevkg@mail.gmail.com>
 <20131115.174426.1448825246187940374.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhelgaas@google.com, pomac@vapor.com, linux-kernel@vger.kernel.org,
	edumazet@google.com, netdev@vger.kernel.org, alex.aring@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131115.174426.1448825246187940374.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 15, 2013 at 05:44:26PM -0500, David Miller wrote:
> From: Bjorn Helgaas <bhelgaas@google.com>
> Date: Fri, 15 Nov 2013 15:29:53 -0700
> 
> > [+cc David, Eric, Alex, netdev]
> > 
> > Alex reported a similar issue at
> > http://marc.info/?l=linux-netdev&m=138355719901790&w=4
> 
> Fixed by:
> 
> commit 84502b5ef9849a9694673b15c31bd3ac693010ae
> Author: Steffen Klassert <steffen.klassert@secunet.com>
> Date:   Wed Oct 30 11:16:28 2013 +0100

Cherry-picked, compiled and preparing for reboot - thanks!

Shouldn't this be queued up in stable sometime soonish?

(Sorry for the change of email address, i had forgot to switch the
configurations in mutt)
