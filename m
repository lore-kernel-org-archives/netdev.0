From: "Leonid Grossman" <leonid.grossman@s2io.com>
Subject: RE: The ultimate TOE design
Date: Fri, 24 Sep 2004 06:21:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409241321.i8ODLf39012346@guinness.s2io.com>
References: <20040924130738.GB24093@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>,
        "'Jeff Garzik'" <jgarzik@pobox.com>, <alan@lxorguk.ukuu.org.uk>,
        <paul@clubi.ie>, <netdev@oss.sgi.com>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Lennert Buytenhek'" <buytenh@wantstofly.org>
In-Reply-To: <20040924130738.GB24093@xi.wantstofly.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: Lennert Buytenhek [mailto:buytenh@wantstofly.org] 
> Sent: Friday, September 24, 2004 6:08 AM
> To: Leonid Grossman
> Cc: 'David S. Miller'; 'Jeff Garzik'; 
> alan@lxorguk.ukuu.org.uk; paul@clubi.ie; netdev@oss.sgi.com; 
> linux-kernel@vger.kernel.org
> Subject: Re: The ultimate TOE design
> 
> On Wed, Sep 15, 2004 at 04:29:45PM -0700, Leonid Grossman wrote:
> 
> > And at 10GbE, embedded CPUs just don't cut it - it has to be custom 
> > ASIC (granted, with some means to simplify debugging and reduce the 
> > risk of hw bugs and TCP changes).
> 
> Intel's IXP2800 can do 10GbE.

Hi Lennert,
I was referring to the server side. 
One can certanly build a 10GbE box based on IPX2800 (or some other parts),
but at 17-25W it is not usable in NICs since the entire PCI card budget is
less than that - nothing left for 10GbE PHY, memory, etc.
Leonid

> 
> http://www.intel.com/design/network/products/npfamily/ixp2800.htm
> 
> 
> --L
> 
