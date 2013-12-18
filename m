From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 4/5] bonding: add lp_interval attribute netlink
 support
Date: Wed, 18 Dec 2013 13:48:46 +0100
Message-ID: <20131218124846.GD2492@minipsycho.brq.redhat.com>
References: <20131218053030.13529.42150.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:48369 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753536Ab3LRMsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 07:48:50 -0500
Received: by mail-we0-f170.google.com with SMTP id w61so7519875wes.1
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 04:48:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131218053030.13529.42150.stgit@monster-03.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 18, 2013 at 06:30:30AM CET, sfeldma@cumulusnetworks.com wrote:
>Add IFLA_BOND_LP_INTERVAL to allow get/set of bonding parameter
>lp_interval via netlink.
>
>Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
