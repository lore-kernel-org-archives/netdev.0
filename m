From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [PATCH] NETDEBUG network triggerable messages in IPv6
Date: Fri, 09 Apr 2004 11:06:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4076E636.5050803@us.ibm.com>
References: <20040409174847.2f0b7e77.ak@suse.de>	<20040410.010051.129465789.yoshfuji@linux-ipv6.org> <20040409182125.348fd6cd.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>,
        davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040409182125.348fd6cd.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:

> If you don't like it just keep NETDEBUG on. But for production systems being able 
> to fill up logs from the network is not acceptable IMHO. Anyways default behaviour
> does not change right now, it just allows to easily disable all this cruft for
> people who want that.

I'd like to support Andi's patch - or any flavor thereof,
that results in being able to prevent nw triggered
logging filling up logs. It is very much needed by us,
too. I would like to see it be the default in mainline,
really.

thanks,
Nivedita
