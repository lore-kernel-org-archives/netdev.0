From: Ben Greear <greearb@candelatech.com>
Subject: Re: TOE brain dump
Date: Sat, 02 Aug 2003 21:01:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2C891B.7080004@candelatech.com>
References: <20030802140444.E5798@almesberger.net> <3F2BF5C7.90400@us.ibm.com> <3F2C0C44.6020002@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nivedita Singhvi <niv@us.ibm.com>,
   Werner Almesberger <werner@almesberger.net>, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F2C0C44.6020002@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:

> So, fix the other end of the pipeline too, otherwise this fast network 
> stuff is flashly but pointless.  If you want to serve up data from disk, 
> then start creating PCI cards that have both Serial ATA and ethernet 
> connectors on them :)  Cut out the middleman of the host CPU and host 

I for one would love to see something like this, and not just Serial ATA..
but maybe 8x Serial ATA and RAID :)

Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
