From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH net-drivers-2.6 1/5] ixgb: use netif_poll_{enable|disable}
Date: Sun, 20 Feb 2005 21:06:46 -0500
Message-ID: <42194236.40100@pobox.com>
References: <Pine.LNX.4.44.0502151200000.30336-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
To: Malli Chilakala <mallikarjuna.chilakala@intel.com>
In-Reply-To: <Pine.LNX.4.44.0502151200000.30336-100000@isotope.jf.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Malli Chilakala wrote:
> 1 use netif_poll_{enable|disable} to synchronize between poll and i/f down/up

applied patches 1-5.

Please do not include patch numbers (e.g. "1 [...]") in the description; 
I have to hand-edit this out of each comment.

	Jeff
