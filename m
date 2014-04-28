From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] qlcnic driver updates
Date: Sun, 27 Apr 2014 23:21:27 -0400 (EDT)
Message-ID: <20140427.232127.2244548005397527319.davem@davemloft.net>
References: <1398462241-15478-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shahed.shaikh@qlogic.com,
	Dept-HSGLinuxNICDev@qlogic.com
To: jitendra.kalsaria@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36258 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbaD1DVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2014 23:21:32 -0400
In-Reply-To: <1398462241-15478-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Date: Fri, 25 Apr 2014 17:43:55 -0400

> This patch series containes following changes -
> * Optimize MAC learning code.
> * Export board temperature using hwmon-sysfs interface.
> * Add support for configuring Tx interrupt coalescing parameters from VF.
> * Logging error messages in error path.
> * Restrict extended vNIC support in legacy interrupt mode and log appropriate
>   message.
> 
> Please apply this series to net-next.

Series applied, thanks.
