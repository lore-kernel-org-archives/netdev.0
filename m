From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: Favorite network stress tests?
Date: 01 May 2003 02:00:57 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1051747257.8214.195.camel@tux.rsn.bth.se>
References: <20030430163542.4e09076f.shemminger@osdl.org>
	 <3EB060AE.9050708@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3EB060AE.9050708@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2003-05-01 at 01:47, Ben Greear wrote:

> pktgen is good for testing/abusing drivers, below the IP stacks.

Since Stephen is bridge maintainer now I assume he might like esic from
the isic package. It can send packets with random source/destination
macaddresses.
There's a bunch of other small programs in that package as well.

Then there's testlvs and of course diffrent scriptkiddieprograms for
syn/ack/udp/fragment floods with random ip's and ports, they stress the
routingcache and conntrack a lot.

-- 
/Martin
