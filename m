From: "Hen, Shmulik" <shmulik.hen@intel.com>
Subject: RE: [bonding][0/3] Synchronizing 2.4-2.6
Date: Sun, 31 Aug 2003 13:54:55 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E791C176A6139242A988ABA8B3D9B38A014C94E9@hasmsx403.iil.intel.com>
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
> Sent: Sunday, August 31, 2003 12:27 AM
> To: Hen, Shmulik
> Cc: bonding-devel@lists.sourceforge.net; netdev@oss.sgi.com
> Subject: Re: [bonding][0/3] Synchronizing 2.4-2.6
> 
> > Forgot to mention free_netdev().
> > Is it 2.4 compatible ?
> 
> 
> Only if you create a patch for 2.4 :)
> 

I probably didn't phrase the question right. Meant to ask if
free_netdev exists in 2.4 or do we have to export it as was
with alloc_netdev, but hey, I can check this myself now that
I'm at my desk again :).


	Shmulik.
