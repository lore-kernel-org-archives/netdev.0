From: "Dan Rosenberg" <drosenberg@vsecurity.com>
Subject: Re: [PATCH 4/10] Fix leaking of kernel heap addresses in net/
Date: Fri, 12 Nov 2010 02:15:25 +0000
Message-ID: <2129857903-1289528127-cardhu_decombobulator_blackberry.rim.net-1506931048-@bda083.bisx.prod.on.blackberry>
Reply-To: drosenberg@vsecurity.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: socketcan@hartkopp.net, kuznet@ms2.inr.ac.ru,
	urs.thuermann@volkswagen.de, yoshfuji@linux-ipv6.org,
	kaber@trash.net, jmorris@namei.org, remi.denis-courmont@nokia.com,
	pekkas@netcore.fi, sri@us.ibm.com, vladislav.yasevich@hp.com,
	tj@kernel.org, eric.dumazet@gmail.com, lizf@cn.fujitsu.com,
	joe@perches.com, shemminger@vyatta.com, hadi@mojatatu.com,
	ebiederm@xmission.com, adobriyan@gmail.com, jpirko@redhat.com,
	johannes.berg@intel.com, daniel.lezcano@free.fr, xemul@openvz.org,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org,
	"Linus Torvalds" <torvalds@linux-foundation.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp10.bis.na.blackberry.com ([216.9.248.57]:41907 "EHLO
	smtp10.bis.na.blackberry.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751041Ab0KLCPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 21:15:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I am willing to do whatever is necessary to make these changes acceptable.  Are you completely set on not removing these addresses from the output?

-Dan
