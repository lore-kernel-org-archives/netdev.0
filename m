From: todd-lkml@osogrande.com
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Thu, 12 Sep 2002 08:41:25 -0600 (MDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0209120840290.27963-100000@gp>
References: <1031839883.2994.84.camel@irongate.swansea.linux.org.uk>
Reply-To: linux-kernel@vger.kernel.org
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@redhat.com>,
   "tcw@tempest.prismnet.com" <tcw@tempest.prismnet.com>,
   "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
   "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
   patricia gilfeather <pfeather@cs.unm.edu>
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1031839883.2994.84.camel@irongate.swansea.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

alan,

good to know.  it's a nice piece of engineering.  it's useful to note that 
linux has such a long and rich history of breaking de-facto standards in 
order to make things work better.

t.

On 12 Sep 2002, Alan Cox wrote:

> On Thu, 2002-09-12 at 14:57, Todd Underwood wrote:
> > thanks.  although i'd love to take credit, i don't think that the 
> > reverse-order fragmentation appreciation is all that original:  who 
> > wouldn't want their data sctructure size determined up-front? :-) (not to 
> > mention getting header-overwriting for-free as part of the single copy.
> 
> As far as I am aware it was original when Linux first did it (and we
> broke cisco pix, some boot proms, some sco in the process). Credit goes
> to Arnt Gulbrandsen probably better known nowdays for his work on Qt
> 

-- 
todd underwood, vp & cto
oso grande technologies, inc.
todd@osogrande.com

"Those who give up essential liberties for temporary safety deserve
neither liberty nor safety." - Benjamin Franklin
