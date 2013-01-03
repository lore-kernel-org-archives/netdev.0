From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] qlcnic: fix build error
Date: Thu, 03 Jan 2013 01:51:25 -0800 (PST)
Message-ID: <20130103.015125.1938458231171167162.davem@davemloft.net>
References: <1357204215-17607-1-git-send-email-sony.chacko@qlogic.com>
	<1357204215-17607-2-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: sony.chacko@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50044 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753027Ab3ACJv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 04:51:26 -0500
In-Reply-To: <1357204215-17607-2-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>
Date: Thu,  3 Jan 2013 04:10:15 -0500

> From: Sony Chacko <sony.chacko@qlogic.com>
> 
> Fix the following error reported by kbuild test robot.
> static declaration of 'qlcnic_restore_indev_addr' follows
> non-static declaration.
> 
> Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
> Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>

Applied.
