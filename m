From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] qlcnic: Feature addition and enhancements
Date: Fri, 29 Aug 2014 20:16:19 -0700 (PDT)
Message-ID: <20140829.201619.1162285027527194017.davem@davemloft.net>
References: <1409157802-7895-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-GELinuxNICDev@qlogic.com
To: shahed.shaikh@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52694 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224AbaH3DQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 23:16:20 -0400
In-Reply-To: <1409157802-7895-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Date: Wed, 27 Aug 2014 12:43:16 -0400

> This series contains following feature addition and enhancements,
> - Update Link speed and Port type information for 83xx series adapters
> - Support 0x8830 device ID
> - Support for Power on Self Test (POST) feature for 83xx
> - Use usleep_range() instead of msleep() for values less than 20ms

Series applied, thanks.
