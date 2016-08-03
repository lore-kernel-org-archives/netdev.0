From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] qlcnic: bug fixes
Date: Wed, 03 Aug 2016 12:03:51 -0700 (PDT)
Message-ID: <20160803.120351.2004913745649973438.davem@davemloft.net>
References: <1470211324-23430-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-GELinuxNICDev@qlogic.com
To: manish.chopra@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47316 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757971AbcHCTDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 15:03:52 -0400
In-Reply-To: <1470211324-23430-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>
Date: Wed, 3 Aug 2016 04:02:01 -0400

> This series fixes a data structure corruption bug in
> VF's async mailbox commands handling and an issue realted
> to napi poll budget in the driver.
> 
> Please consider applying this series to "net"

Series applied, thanks.
