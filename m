From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: The ultimate TOE design
Date: Wed, 15 Sep 2004 18:26:42 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4148C1A2.2030309@pobox.com>
References: <4148991B.9050200@pobox.com>	<Pine.LNX.4.61.0409152102050.23011@fogarty.jakma.org>	<1095275660.20569.0.camel@localhost.localdomain>	<4148A90F.80003@pobox.com>	<20040915140123.14185ede.davem@davemloft.net>	<20040915210818.GA22649@havoc.gtf.org>	<20040915141346.5c5e5377.davem@davemloft.net>	<4148B2E5.50106@pobox.com> <20040915142926.7bc456a4.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, paul@clubi.ie, netdev@oss.sgi.com,
        leonid.grossman@s2io.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040915142926.7bc456a4.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Wed, 15 Sep 2004 17:23:49 -0400
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> 
>>The typical definition of TOE is "offload 90+% of the net stack", as 
>>opposed to "TCP assist", which is stuff like TSO.
> 
> 
> I think a better goal is "offload 90+% of the net stack cost" which
> is effectively what TSO does on the send side.


A better goal is to not bother with TOE at all, and just get multi-core 
processors with huge memory bandwidth :)

Again, the point of my message is to have something _positive_ to tell 
people when they specifically asked about TOE.  Rather than "no, we'll 
never do TOE" we have "it's possible, but there are better questions you 
should be asking"

	Jeff
