From: Erik Hensema <erik@hensema.net>
Subject: Re: TCP/IPv6 broken in Linux 2.5.64?
Date: Thu, 20 Mar 2003 19:10:05 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030320181004.GA19970@hensema.net>
References: <20030318162532.GA9705@outpost.ds9a.nl> <200303201549.SAA10972@sex.inr.ac.ru> <20030320163107.GA28229@outpost.ds9a.nl>
Reply-To: erik@hensema.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
Content-Disposition: inline
In-Reply-To: <20030320163107.GA28229@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Mar 20, 2003 at 05:31:07PM +0100, bert hubert wrote:
> On Thu, Mar 20, 2003 at 06:49:49PM +0300, kuznet@ms2.inr.ac.ru wrote:
> > Hello!
> > 
> > > irc servers, or an IPv6 zonetransfer. However, when I try to ssh from 2.5.65
> > 
> > Try this. I have just found this lost patch, it is from 2.4 tree, but
> > it should fit to 2.5 as well.
> 
> This has solved my problem 100%. The earlier mentioned hostA and hostB can
> now cheerfully connect to eachother. Everything else I try works too.
> 
> So I suggest this be sent linus-wards. Thanks!

I can confirm that this fixed my IPv6 problems on 2.5.x.

-- 
Erik Hensema (erik@hensema.net)
