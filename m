From: Greg Kroah-Hartman <greg@kroah.com>
Subject: Re: [PATCH] fix infoleak in wireless
Date: Tue, 3 May 2016 14:00:52 -0700
Message-ID: <20160503210052.GA23109@kroah.com>
References: <1462308013-6032-1-git-send-email-kjlu@gatech.edu>
 <1462308044.10444.19.camel@sipsolutions.net>
 <CABEk9YxqyBxnqOseJ3-d-aKxnREZBFt1z89nOjHf=DvNQy_hTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>, davem@davemloft.net,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Kangjie Lu <kjlu@gatech.edu>
To: Kangjie Lu <kangjielu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CABEk9YxqyBxnqOseJ3-d-aKxnREZBFt1z89nOjHf=DvNQy_hTw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


A: No.
Q: Should I include quotations after my reply?

http://daringfireball.net/2007/07/on_top

On Tue, May 03, 2016 at 04:47:16PM -0400, Kangjie Lu wrote:
> Hi Greg,
> 
> Could you please take a look at this issue.
> mac_addr is not initialized is some implementations of dump_station(), which
> can be exploited by attackers for leaking information.

You are going to have to give me more context here...

Like the patch itself?

thanks,

greg k-h
