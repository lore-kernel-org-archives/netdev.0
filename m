From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH 1/4] clip: run through Lindent
Date: Thu, 13 Apr 2006 15:45:29 -0700
Message-ID: <20060413224529.GA2476@kroah.com>
References: <20060412105545.3b089dd8@localhost.localdomain> <20060413152224.2d46df99@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, chas@cmf.nrl.navy.mil,
	netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net,
	stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:21186 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1751135AbWDMWqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2006 18:46:38 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060413152224.2d46df99@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 13, 2006 at 03:22:24PM -0700, Stephen Hemminger wrote:
> Run CLIP driver through Lindent script to fix formatting.

That's well and good, but really not a -stable thing.  In fact, I don't
see any of these 4 patches being -stable material, do you?

thanks,

greg k-h
