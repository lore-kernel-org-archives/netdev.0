From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.70] Add release_netdev -- hook for sysfs/net device
 cleanup
Date: Mon, 09 Jun 2003 10:18:07 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030609.101807.119873069.davem@redhat.com>
References: <3EE4BF39.2020503@pobox.com>
	<20030609.100948.84378474.davem@redhat.com>
	<20030609171446.GA15239@gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
In-Reply-To: <20030609171446.GA15239@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Jeff Garzik <jgarzik@pobox.com>
   Date: Mon, 9 Jun 2003 13:14:46 -0400
   
   I wanted to wait on the s/kfree/release_netdev/ patch until the other
   stuff is done.  Said patch can be applied anytime, and doing it in this
   order reduces 2.4 backport merge pain.  :)

No problem, but once all the init_etherdev() etc. crap is abolished,
Stephen's work or something similar goes in...

Ok?
