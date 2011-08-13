From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [net-next 12/12] drivers/net: Kconfig and Makefile cleanup
Date: Sat, 13 Aug 2011 11:21:05 -0400
Message-ID: <4E469661.5090505@pobox.com>
References: <1313222196-10074-1-git-send-email-jeffrey.t.kirsher@intel.com> <1313222196-10074-13-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:48017 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864Ab1HMPVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Aug 2011 11:21:11 -0400
Received: by qwk3 with SMTP id 3so1941406qwk.19
        for <netdev@vger.kernel.org>; Sat, 13 Aug 2011 08:21:10 -0700 (PDT)
In-Reply-To: <1313222196-10074-13-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/13/2011 03:56 AM, Jeff Kirsher wrote:
> After the move of the Ethernet drivers into drivers/net/ethernet/
> there was some leftover cleanup to do in the Kconfig and Makefile.
>
> Removed the 10/100, 1000, and 10GbE Kconfig menus.
>
> Removed the out-dated pci-skeleton.c file which was used an
> example driver.  With the current networking features and
> structure, the file is no longer a good example to use for
> driver creation.
>
> CC: Jeff Garzik<jgarzik@pobox.com>
> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
Acked-by: Jeff Garzik <jgarzik@redhat.com>


