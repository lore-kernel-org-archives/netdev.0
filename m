From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: 12 Sep 2002 15:11:23 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1031839883.2994.84.camel@irongate.swansea.linux.org.uk>
References: <Pine.LNX.4.44.0209120729200.27963-100000@gp>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, "David S. Miller" <davem@redhat.com>,
   "tcw@tempest.prismnet.com"
	 <tcw@tempest.prismnet.com>,
   "linux-kernel@vger.kernel.org"
	 <linux-kernel@vger.kernel.org>,
   "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
   patricia gilfeather <pfeather@cs.unm.edu>
Return-path: <netdev-bounce@oss.sgi.com>
To: Todd Underwood <todd@osogrande.com>
In-Reply-To: <Pine.LNX.4.44.0209120729200.27963-100000@gp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2002-09-12 at 14:57, Todd Underwood wrote:
> thanks.  although i'd love to take credit, i don't think that the 
> reverse-order fragmentation appreciation is all that original:  who 
> wouldn't want their data sctructure size determined up-front? :-) (not to 
> mention getting header-overwriting for-free as part of the single copy.

As far as I am aware it was original when Linux first did it (and we
broke cisco pix, some boot proms, some sco in the process). Credit goes
to Arnt Gulbrandsen probably better known nowdays for his work on Qt
