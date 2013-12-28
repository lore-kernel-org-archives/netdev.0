From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/4] bonding: add lacp_rate attribute netlink
 support
Date: Sat, 28 Dec 2013 22:24:11 +0100
Message-ID: <20131228212411.GB2447@minipsycho>
References: <20131228071541.6296.29310.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:58549 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919Ab3L1VYP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Dec 2013 16:24:15 -0500
Received: by mail-ee0-f54.google.com with SMTP id e51so3838346eek.41
        for <netdev@vger.kernel.org>; Sat, 28 Dec 2013 13:24:14 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131228071541.6296.29310.stgit@monster-03.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Dec 28, 2013 at 08:15:41AM CET, sfeldma@cumulusnetworks.com wrote:
>Add IFLA_BOND_AD_LACP_RATE to allow get/set of bonding parameter
>lacp_rate via netlink.
>
>Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
