From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] tg3.h & b44.h ifndef ADVERTISE_PAUSE typo
Date: Tue, 11 Jan 2005 15:07:13 -0500
Message-ID: <41E431F1.8040401@pobox.com>
References: <1105454553.4264.4.camel@dhollis-lnx.centricconsulting.com>	 <41E421A8.60203@pobox.com> <1105472929.6599.3.camel@dhollis-lnx.centricconsulting.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Hollis <dhollis@davehollis.com>
In-Reply-To: <1105472929.6599.3.camel@dhollis-lnx.centricconsulting.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David Hollis wrote:
> On Tue, 2005-01-11 at 13:57 -0500, Jeff Garzik wrote:
> 
> 
>>Just kill the ifdef and add it to mii.h.
>>
>>	Jeff
>>
> 
> 
> Attached patch moves those defines to mii.h and removes them from tg3.h
> & b44.h.

ACK, I'll merge this up David...

	Jeff
