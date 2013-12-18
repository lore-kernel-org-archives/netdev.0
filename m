From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 5/5] bonding: add packets_per_slave attribute
 netlink support
Date: Wed, 18 Dec 2013 13:49:00 +0100
Message-ID: <20131218124900.GE2492@minipsycho.brq.redhat.com>
References: <20131218053037.13529.67219.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:57502 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753118Ab3LRMtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 07:49:04 -0500
Received: by mail-we0-f174.google.com with SMTP id q58so7516656wes.33
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 04:49:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131218053037.13529.67219.stgit@monster-03.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 18, 2013 at 06:30:37AM CET, sfeldma@cumulusnetworks.com wrote:
>Add IFLA_BOND_PACKETS_PER_SLAVE to allow get/set of bonding parameter
>packets_per_slave via netlink.
>
>Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
