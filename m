From: jamal <hadi@cyberus.ca>
Subject: Re: [SET 2][PATCH 2/8][bonding] Propagating master's settings to
	slaves
Date: 08 Aug 2003 18:01:16 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1060380076.1717.233.camel@jzny.localdomain>
References: <200308081744.58946.shmulik.hen@intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shmulik.hen@intel.com
In-Reply-To: <200308081744.58946.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Shmulik,

Some of this bonding stuff is pretty scary. Lotsa policies in the 
kernel and communication seems to be centred around /proc.
Shouldnt policies on failover be really driven from user space?
Also shouldnt communication be using something like netlink?

cheers,
jamal

On Fri, 2003-08-08 at 10:44, Shmulik Hen wrote:
> 2 - Change monitoring function use the new functionality.
> 
