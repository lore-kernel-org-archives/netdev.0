From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH 0/2] iproute2: Support for CAN network devices
Date: Wed, 20 May 2009 09:54:19 +0200
Message-ID: <4A13B72B.5070206@grandegger.com>
References: <20090512094248.439786706@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:59045 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754218AbZETHyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 03:54:22 -0400
In-Reply-To: <20090512094248.439786706@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wolfgang Grandegger wrote:
> Hello,
> 
> here are the patches for the "ip" program of the iproute2 utility
> suite adding support for CAN netlinks.
> 
>   1/2) iproute2: Fixes an issue with cross-compilation
>   2/2) iproute2: Support for the CAN netlink
> 
> The first patch is required to get it cross-compiled.
> 
> The patches are based on v2 of the patch series for the Linux kernel
> with the subject:
> 
>   [PATCH v2 0/7] can: CAN network device driver interface and drivers
> 
> posted a few minutes ago:
> 
>   http://marc.info/?l=linux-netdev&m=124212048701347&w=2
> 
> Please consider these patches for inclusion when the Linux kernel
> patches have been accepted.

The mentioned Socket-CAN kernel patches including netlink support have
been accepted in the meantime, see:
http://marc.info/?l=linux-netdev&m=124268656617653&w=2

Thanks,

Wolfgang.

