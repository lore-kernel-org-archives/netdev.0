From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 2/5] bonding: add all_slaves_active attribute
 netlink support
Date: Wed, 18 Dec 2013 13:48:19 +0100
Message-ID: <20131218124819.GB2492@minipsycho.brq.redhat.com>
References: <20131218053016.13529.63686.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:35854 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753536Ab3LRMsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 07:48:22 -0500
Received: by mail-wi0-f169.google.com with SMTP id hn6so5010907wib.4
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 04:48:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131218053016.13529.63686.stgit@monster-03.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 18, 2013 at 06:30:16AM CET, sfeldma@cumulusnetworks.com wrote:
>Add IFLA_BOND_ALL_SLAVES_ACTIVE to allow get/set of bonding parameter
>all_slaves_active via netlink.
>
>Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
