From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ieee80211 subsystem
Date: Tue, 08 Feb 2005 18:25:33 -0500
Message-ID: <42094A6D.9080508@pobox.com>
References: <4203C32A.70402@linux.intel.com> <20050208042950.GD8366@jm.kir.nu> <420885B6.7090606@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkmaline@cc.hut.fi>, netdev@oss.sgi.com
To: James Ketrenos <jketreno@linux.intel.com>
In-Reply-To: <420885B6.7090606@linux.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Just to keep everything moving, my recommendation would be to move the 
code to net/*, and resend the patch (with whatever changes you have made 
to date).

That way you, and others, can review and work on the tree in parallel.

I'm worried that your list of todo items (based on responses so far) is 
already so long that I won't hear from you for another year ;-)  We need 
to get the wireless-2.6 tree active again, and avoid bottlenecks.  We 
need "release early, release often."

	Jeff
