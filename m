From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: Intel and TOE in the news
Date: Tue, 22 Feb 2005 13:30:21 -0800
Message-ID: <200502222131.j1MLVHDD029755@guinness.s2io.com>
References: <421BA204.704@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "'Rick Jones'" <rick.jones2@hp.com>, <netdev@oss.sgi.com>
In-Reply-To: <421BA204.704@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

No wait, "paste in" only packets that are already received when a traffic
interrupt comes...
At 10GbE, the entire window will likely be sitting there :-)

Leonid 

> -----Original Message-----
> From: netdev-bounce@oss.sgi.com 
> [mailto:netdev-bounce@oss.sgi.com] On Behalf Of Rick Jones
> Sent: Tuesday, February 22, 2005 1:20 PM
> To: netdev@oss.sgi.com
> Subject: Re: Intel and TOE in the news
> 
> I always thought the biggest issue with "RSO" would be 
> deciding how long to wait for another segment to paste-in 
> with the rest?
> 
> rick jones
> 
> all the previous talk about header/data split makes me wax 
> nostalgic for the FDDI adaptors of the late 80's and early 
> 90's that did that - back when MTU's were >= page size and 
> life was good :) :) :)
> 
> 
