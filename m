From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: OSDL Bugzilla #2399: A user can remotely route a packet through
 eth0 on a Linux machine
Date: Tue, 11 May 2004 12:15:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40A12646.7080605@us.ibm.com>
References: <OF94DCEE79.E30FBAF0-ON88256E91.0067773D-88256E91.0067C495@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, snortwiz@hotmail.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF94DCEE79.E30FBAF0-ON88256E91.0067773D-88256E91.0067C495@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David Stevens wrote:
> Routing is something done between different hosts. Hosts normally
> will accept packets for any local  address, regardless of
> which interface it was received on.
> 
> That's not a bug; that's how almost everything works.

I think the only issue here is if an application that
binds to an interface should see packets coming in
from another - if that is what is happening here?.

thanks,
Nivedita
