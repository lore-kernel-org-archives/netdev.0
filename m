From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 4/4] switchdev: documentation: use
 switchdev_port_obj_xxx for IPv4 FIB add/modify/delete ops
Date: Thu, 4 Jun 2015 08:17:37 +0200
Message-ID: <20150604061737.GE2134@nanopsycho.orion>
References: <1433389423-58467-1-git-send-email-sfeldma@gmail.com>
 <1433389423-58467-5-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, gospo@cumulusnetworks.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:33145 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752322AbbFDGRl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 02:17:41 -0400
Received: by wgez8 with SMTP id z8so25351998wge.0
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 23:17:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1433389423-58467-5-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jun 04, 2015 at 05:43:43AM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Clarify in documentation and code that IPV4 FIB add operation is used for
>both adding a new FIB entry to the device and for modifying an existing FIB
>entry on the device.
>
>Also, remove left-over references to ipv4_fib ops and replace with details
>on SWITCHDEV_PORT_IPV4_FIB object.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>
