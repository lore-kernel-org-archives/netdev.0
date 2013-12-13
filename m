From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 4/8] bonding: add use_carrier netlink support
Date: Fri, 13 Dec 2013 08:29:44 +0100
Message-ID: <20131213072944.GD2486@minipsycho.orion>
References: <20131212221016.21629.93325.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:40555 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152Ab3LMH3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 02:29:47 -0500
Received: by mail-ee0-f41.google.com with SMTP id t10so678800eei.14
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 23:29:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131212221016.21629.93325.stgit@monster-03.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Dec 12, 2013 at 11:10:16PM CET, sfeldma@cumulusnetworks.com wrote:
>Add IFLA_BOND_USE_CARRIER to allow get/set of bonding parameter
>use_carrier via netlink.
>
>Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
