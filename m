From: Andi Kleen <ak@muc.de>
Subject: Re: FIN_WAIT1 / TCP_CORK / 2.2 -- reproducible bug and test case
Date: Thu, 3 Oct 2002 05:54:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021003035446.GA29860@averell>
References: <1033388585.16337.9.camel@irongate.swansea.linux.org.uk> <Mutt.LNX.4.44.0210031329450.13240-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Martin Pool <mbp@samba.org>,
   "David S. Miller" <davem@redhat.com>, kuznet@ms2.inr.ac.ru, ak@muc.de,
   netdev@oss.sgi.com, Alan.Cox@linux.org
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@intercode.com.au>
Content-Disposition: inline
In-Reply-To: <Mutt.LNX.4.44.0210031329450.13240-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 03, 2002 at 05:30:44AM +0200, James Morris wrote:
> On 30 Sep 2002, Alan Cox wrote:
> 
> > Well if Dave can't test it and isnt doing any 2.2 who wants to be the
> > 2.2 networking maintainer ?
> > 
> 
> I'd be willing to give it a go.

2.2 networking unfortunately has some more SMP bugs (DaveM can tell you details)
which are hard to fix. So think twice before you volunteer ;)

-Andi
