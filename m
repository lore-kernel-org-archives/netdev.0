From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 3/5] bonding: add min_links attribute netlink
 support
Date: Wed, 18 Dec 2013 13:48:34 +0100
Message-ID: <20131218124834.GC2492@minipsycho.brq.redhat.com>
References: <20131218053023.13529.82243.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:56166 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753536Ab3LRMsh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 07:48:37 -0500
Received: by mail-wg0-f52.google.com with SMTP id x13so7481682wgg.19
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 04:48:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131218053023.13529.82243.stgit@monster-03.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 18, 2013 at 06:30:23AM CET, sfeldma@cumulusnetworks.com wrote:
>Add IFLA_BOND_MIN_LINKS to allow get/set of bonding parameter
>min_links via netlink.
>
>Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
