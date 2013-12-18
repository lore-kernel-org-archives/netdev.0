From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/5] bonding: add num_grat_arp attribute netlink
 support
Date: Wed, 18 Dec 2013 13:48:03 +0100
Message-ID: <20131218124803.GA2492@minipsycho.brq.redhat.com>
References: <20131218053009.13529.4563.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:42605 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753536Ab3LRMsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 07:48:07 -0500
Received: by mail-wg0-f45.google.com with SMTP id y10so7480157wgg.12
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 04:48:06 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131218053009.13529.4563.stgit@monster-03.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 18, 2013 at 06:30:09AM CET, sfeldma@cumulusnetworks.com wrote:
>Add IFLA_BOND_NUM_PEER_NOTIF to allow get/set of bonding parameter
>num_grat_arp via netlink.  Bonding parameter num_unsol_na is
>synonymous with num_grat_arp, so add only one netlink attribute
>to represent both bonding parameters.
>
>Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
