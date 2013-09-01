From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] qlcnic: Enhancements and cleanup
Date: Sat, 31 Aug 2013 22:35:48 -0400 (EDT)
Message-ID: <20130831.223548.2038236658068165285.davem@davemloft.net>
References: <1377885084-6441-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-HSGLinuxNICDev@qlogic.com
To: shahed.shaikh@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45979 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752526Ab3IACfu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Aug 2013 22:35:50 -0400
In-Reply-To: <1377885084-6441-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Date: Fri, 30 Aug 2013 13:51:15 -0400

> From: Shahed Shaikh <shahed.shaikh@qlogic.com>
> 
> This patch series contains -
> * Enhanced PVID handling for 84xx adapters by
>   not indicating PVID configuration to VF driver and
>   keeping VF driver in no VLAN configuration mode becasue
>   adapter supports VLAN stripping.
> * Removed inappropriate usage of inline keyword.
> * Enhanced minidump feature by using firmware recommended
>   dump capture mask and using CAMRAM register to store
>   firmware dump state.
> * AER handling support for 83xx adapter.
> * Added support for per port eswitch configuration.
> 
> Please apply to net-next.

Series applied, thank you.
