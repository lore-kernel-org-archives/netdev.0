From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Steps for netdev-2.6 inclusion?
Date: Tue, 21 Dec 2004 15:03:15 -0500
Message-ID: <41C88183.3020906@pobox.com>
References: <41AE7143.80505@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Ketrenos <jketreno@linux.intel.com>
In-Reply-To: <41AE7143.80505@linux.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

James Ketrenos wrote:
> 
> Ok, its been a long time coming, but it appears the ipw* wireless 
> drivers are to the point where being more proactive at getting them into 
> the kernel is appropriate (at least based on the frequency of emails I'm 
> getting of 'why isn't this in mainline?')
> 
> So, what would be the set of steps required to get a version in the 
> queue for inclusion?

Any updates?  Where do we stand with this?

I would suggest sending a patch for each driver, diff'd against -mm 
(which auto-includes my netdev-2.6 and wireless-2.6 queues).

	Jeff
