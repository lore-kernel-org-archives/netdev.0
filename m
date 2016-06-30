From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next V2 08/16] net/devlink: Add E-Switch mode control
Date: Thu, 30 Jun 2016 17:40:00 +0200
Message-ID: <20160630154000.GF2569@nanopsycho.orion>
References: <1467300215-14199-1-git-send-email-saeedm@mellanox.com>
 <1467300215-14199-9-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:36235 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932430AbcF3PkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 11:40:03 -0400
Received: by mail-wm0-f54.google.com with SMTP id f126so227165922wma.1
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 08:40:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1467300215-14199-9-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jun 30, 2016 at 05:23:27PM CEST, saeedm@mellanox.com wrote:
>From: Or Gerlitz <ogerlitz@mellanox.com>
>
>Add the commands to set and show the mode of SRIOV E-Switch, two modes
>are supported:
>
>* legacy: operating in the "old" L2 based mode (DMAC --> VF vport)
>
>* switchdev: the E-Switch is referred to as whitebox switch configured
>using standard tools such as tc, bridge, openvswitch etc. To allow
>working with the tools, for each VF, a VF representor netdevice is
>created by the E-Switch manager vendor device driver instance (e.g PF).
>
>Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
