From: Wes Felter <wesley@felter.org>
Subject: Re: The ultimate TOE design
Date: Wed, 15 Sep 2004 16:35:31 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <ciacj6$bfj$1@sea.gmane.org>
References: <4148991B.9050200@pobox.com> <Pine.LNX.4.61.0409152102050.23011@fogarty.jakma.org> <4148A561.5070401@redhat.com> <ciaao4$crc$1@sea.gmane.org> <20040915211543.GA23906@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20040915211543.GA23906@havoc.gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:

> On Wed, Sep 15, 2004 at 04:03:57PM -0500, Wes Felter wrote:
> 
>>To do 10 Gbps Ethernet with Jeff's approach, wouldn't you need a 5-10 
>>GHz processor on the card? Sounds expensive.
> 
> 
> Do you need a 5-10 Ghz Intel server to handle 10 Gbps ethernet?

Yes. (Or a 4-way ~2GHz server.)

When the fastest general-purpose processors cannot handle the fastest 
Ethernet links, putting such a processor on a NIC won't help much. I 
think this is why people are attracted to TOE ASICs, even if that isn't 
the right solution.

-- 
Wes Felter - wesley@felter.org - http://felter.org/wesley/
