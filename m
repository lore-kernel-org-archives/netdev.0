From: "Hen, Shmulik" <shmulik.hen@intel.com>
Subject: RE: [bonding][2/3] Synchronizing 2.4-2.6
Date: Thu, 28 Aug 2003 10:26:31 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E791C176A6139242A988ABA8B3D9B38A014C94E5@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Jeff Garzik" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Jeff Garzik [mailto:jgarzik@pobox.com]
> Sent: Thursday, August 28, 2003 12:52 AM
> To: Hen, Shmulik
> Cc: bonding-devel@lists.sourceforge.net; netdev@oss.sgi.com
> Subject: Re: [bonding][2/3] Synchronizing 2.4-2.6
> 
> 
> Shmulik Hen wrote:
> > This is set 2 that merges parts of Jay Vosburgh's experimental
> > propagation stuff from 5/22 with all the fixes/enhancements
> > we've developed according to the RFC published on bond-devel
> > list on 6/2.
> > 
> > Applies on 2.4.22. Assumes patch set 1 was already applied.
> 
> 
> As Jay mentioned he had approved through the end of set 2, and set 2 
> looks good to me, I applied all 8 patches to 2.4.
> 

Does that mean patch set 2 was also applied ?
Because that was the first thing to do to get versions synched.

> Let's now take an operational pause in 2.4, and get 2.6 back 
> into sync. 
>   Would some hearty bonding team member(s) be willing to do that?
> 

After patch set 1, It should be as easy as just copying all the
bonding related files from 2.4 to 2.6. I guess I can do that on
Sunday if someone hasn't already done it before.

> I would _really_ prefer that the revision history be 
> maintained, which 
> makes it a non-trivial exercise, time-wise...

Where should that be maintained ?
I could suggest the CVS on SFG.


	Shmulik.
