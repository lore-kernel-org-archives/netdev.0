From: "Hen, Shmulik" <shmulik.hen@intel.com>
Subject: RE: reasons for dev_alloc_skb +16?
Date: Wed, 9 Jul 2003 18:35:33 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E791C176A6139242A988ABA8B3D9B38A014C93BA@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Jeff Garzik" <jgarzik@pobox.com>, <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Could be for alignment issues.
Or preparation for things like 8021q tagging.


	Shmulik.

> -----Original Message-----
> From: Jeff Garzik [mailto:jgarzik@pobox.com]
> Sent: Wednesday, July 09, 2003 6:26 PM
> To: netdev@oss.sgi.com
> Subject: reasons for dev_alloc_skb +16?
> 
> 
> I knew this at one time, but have forgotten it :)
> 
> What is the reason for adding 16 to the dev_alloc_skb length?
> (and skb_reserve of the same length)
> 
> 	Jeff
> 
> 
> 
