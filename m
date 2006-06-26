From: Chad Hanson <chanson@TrustedCS.com>
Subject: RE: [PATCH 01/06] MLSXFRM: Granular IPSec associations for use in
	  MLS environments
Date: Mon, 26 Jun 2006 18:24:28 -0400
Message-ID: <36282A1733C57546BE392885C0618592013246F8@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:15876 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S933078AbWFZWY4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 18:24:56 -0400
To: James Morris <jmorris@namei.org>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
> There's also the question of ongoing maintenance in the
> mainline kernel.  Unfortunately, there's been an increasing
> trend recently for companies to drop code over the wall.  For 
> example, once they get it to some basic level of completeness,
> and the initial patches are merged, their developers are 
> reassigned to other projects and the upstream maintainers 
> are left with code that's not yet up to Linux kernel quality
> and also something they may not understand very well.  So, we
> need to know whether TCS or anyone else with expert knowledge
> of MLS will be helping months or years down the track, once this
> code has been merged.

We are prepared to help with ongoing support for maintenance and 
improvement of the code accepted into the kernel. We like having
the benefit of providing guidance for the OS security development,
which is needed for our solutions, even though there is some added
cost. This is one the reasons we are porting our solutions to Linux.
The bottom line is the security functionality is a necessary 
component for our applications, and we don't want to be dependent
on others to make sure the functionality is being maintained
correctly. 

-Chad
