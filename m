From: David Miller <davem@davemloft.net>
Subject: Re: [git patches] net driver updates for .28
Date: Sat, 20 Sep 2008 03:33:36 -0700 (PDT)
Message-ID: <20080920.033336.39652163.davem@davemloft.net>
References: <20080914022236.GA15673@havoc.gtf.org>
	<20080920.000914.219711773.davem@davemloft.net>
	<48D4A618.5080403@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: brice@myri.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753744AbYITKeG@vger.kernel.org>
In-Reply-To: <48D4A618.5080403@myri.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Brice Goglin <brice@myri.com>
Date: Sat, 20 Sep 2008 09:28:24 +0200

> Ok, I'll resend without the select_queue stuff. But you should really
> document the above explanation. The only documentation we found was
> "Devices or device layers can set this to control the queue selection
> performed by dev_pick_tx()." in the git-log...

Sure.

On your part, I would suggest that when you run into a problem that
many other multiqueue drivers will likely face, that you bring it up
here for discussion instead of implementing localized solutions :-)
