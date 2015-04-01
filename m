From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 00/26] switchdev: spring cleanup
Date: Wed, 1 Apr 2015 13:40:26 +0200
Message-ID: <20150401114026.GB2025@nanopsycho.orion>
References: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com,
	sridhar.samudrala@intel.com, ronen.arad@intel.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:33520 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256AbbDALk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 07:40:29 -0400
Received: by wgoe14 with SMTP id e14so49930621wgo.0
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 04:40:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 01, 2015 at 12:07:36PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>v2:
>
>Address review comments:
>
> - [Jiri] squash a few related patches
> - [Roopa] don't remove NETIF_F_HW_SWITCH_OFFLOAD
> - [Roopa] address VLAN setlink/dellink
> - [Ronen] print warning is attr set revert fails
>
>Not address:
>
> - Using something other than "swdev_" prefix

I do not understand why this was not addresses. Can you please provide some
justification?
