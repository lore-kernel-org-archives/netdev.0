From: Derek Atkins <warlord@MIT.EDU>
Subject: Re: ipsec-tools 0.1 + kernel 2.5.64
Date: 05 Mar 2003 09:52:44 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <sjm1y1lyif7.fsf@kikki.mit.edu>
References: <1046863752.441.7.camel@simulacron>
	<20030305112852.GA22351@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Jellinghaus <aj@dungeon.inka.de>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20030305112852.GA22351@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

bert hubert <ahu@ds9a.nl> writes:

> On Wed, Mar 05, 2003 at 12:29:12PM +0100, Andreas Jellinghaus wrote:
> > Hi,
> > 
> > both manual keying and automatic keying with racoon (pre-shared secret)
> > are working fine. No need to patch or modify anything. 
> > I tried only ipv4.
> 
> By the way, regarding ipsec-tools 0.1, are you sure you want to fork the
> projects involved?

I spoke to the KAME people and unfortunately, at least for now, there
is no other choice but to fork.  Perhaps down the road we can merge,
but as of last week they don't want to host a linux package.  They are
willing to take some of our patches, but that doesn't help with a
build system.

> By the way, you did not mention it here but ipsec-tools is available on
> http://sourceforge.net/projects/ipsec-tools , I also link them from
> http://lartc.org/howto/lartc.ipsec.html

I didn't?   Perhaps I said ipsec-tool.sourceforge.net which has a
link to sourceforge.net/projects/ipsec-tools and is much shorter
to type. ;) 

> Regards,
> 
> bert

-derek

-- 
       Derek Atkins, SB '93 MIT EE, SM '95 MIT Media Laboratory
       Member, MIT Student Information Processing Board  (SIPB)
       URL: http://web.mit.edu/warlord/    PP-ASEL-IA     N1NWH
       warlord@MIT.EDU                        PGP key available
