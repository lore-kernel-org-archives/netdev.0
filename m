From: "Hen, Shmulik" <shmulik.hen@intel.com>
Subject: RE: [PATCH] network device renaming sysfs fix
Date: Fri, 15 Aug 2003 14:36:27 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E791C176A6139242A988ABA8B3D9B38A014C949E@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@redhat.com>, "Mark Huth" <mhuth@mvista.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Dan Aloni" <da-x@gmx.net>, "Linux Net-Dev" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Dan Aloni [mailto:da-x@gmx.net]
> Sent: Friday, August 15, 2003 2:15 PM
> To: Linux Net-Dev
> Cc: David S. Miller; Mark Huth
> Subject: [PATCH] network device renaming sysfs fix
> 
> 
> (repost, now will hopefully reach the mailing list)
> 
> I believe this is a better approach for fixing the sysfs renaming
> discrepancy. Later I'll also look into fixing the same issue 
> with sysctl.
> 
> 
> -- 
> Dan Aloni
> da-x@gmx.net
> 
> 

In general, it a similar thing applicable for proc fs too ?
We just had to fix something like that in bonding, and
it sounds odd each driver should handle this on it's own.

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
