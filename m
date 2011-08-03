From: David Miller <davem@redhat.com>
Subject: Re: [PATCH 0/3] bna: Remove get_reg support and HW reg
 consolidation
Date: Wed, 03 Aug 2011 03:27:37 -0700 (PDT)
Message-ID: <20110803.032737.1740279402865331589.davem@redhat.com>
References: <1312324567-18487-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56699 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754012Ab1HCK1j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2011 06:27:39 -0400
In-Reply-To: <1312324567-18487-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Tue, 2 Aug 2011 15:36:04 -0700

>    This patch-set removes get_regs ethtool support and consists of HW reg
>    consolidation to support various Brocade HW.
> 
>    The driver has been compiled and tested against net-next-2.6(3.0.0-rc7)
> 
> Rasesh Mody (3):
>   bna: Remove get_regs Ethtool Support
>   bna: Consolidated HW Registers for Supported HWs
>   bna: Remove Obsolete File bfi_ctreg.h

Queued up for net-next, thanks.
