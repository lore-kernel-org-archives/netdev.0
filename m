From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] qlcnic: enhancements
Date: Mon, 10 Aug 2015 13:34:50 -0700 (PDT)
Message-ID: <20150810.133450.366990134543320574.davem@davemloft.net>
References: <1438946227-11426-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-GELinuxNICDev@qlogic.com
To: shahed.shaikh@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44202 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753793AbbHJUev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 16:34:51 -0400
In-Reply-To: <1438946227-11426-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Date: Fri, 7 Aug 2015 07:17:01 -0400

> This series adds few enhancements.
> 
>   o Patch from Harish reorders the sequence of header files inclusion,
>     keeping kernel's header files on top.
> 
>   o Firmware introduced a new feature which allows driver to increases
>     the size of firmware dump of iSCSI function which is being collected
>     by NIC driver.
> 
>   o Print buffer address which is holding a firmware dump.
> 
>   o Use vzalloc() instead kzalloc() for allocating large chunk of memory
>     which will avoid potential memory allocation failure.
> 
>   o Add new device ID for 0x8C30 which is a 83xx series based VF function.
> 
> Please apply this series to net-next.

Series applied, thanks.
