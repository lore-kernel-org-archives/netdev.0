From: David Miller <davem@davemloft.net>
Subject: patchwork for netdev
Date: Thu, 18 Sep 2008 16:56:07 -0700 (PDT)
Message-ID: <20080918.165607.55765591.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, linville@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44209
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755022AbYIRX4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 19:56:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


During the kernel summit, Paul Mackerras gave an excellent presention
on the patchwork web based tool they are using for powerpc platform
development.

In a nutshell, it's a web tool that gets fed by a mailing list and
records patches.  Administrators for a "project" can change the
state of the patches, edit them, put them into bundles, etc.
And everyone can look at the state of the patch queue and also
look up older patches that were rejected, deferred, accepted, etc.

It looks like it can streamline our workflow as well as give people
a place to see what state their patch is in.  So I've asked the
ozlabs folks to create a "netdev" project.

See for yourself:

	http://patchwork.ozlabs.org/project/netdev/list/

Currently I am the admin for this project.

It might be nice if Jeff Garzik created an account for himself,
so I can get him marked as an admin as well, since driver patches
get funneled there too.

John Linville, on the other hand, may wish to ask the ozlabs folks
to add a linux-wireless project and admin that project.

John, I'll send you a contact under private cover that you can use
if interested.
