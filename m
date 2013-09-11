From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] qlcnic: Fix warning reported by kbuild test
 robot.
Date: Wed, 11 Sep 2013 16:00:13 -0400 (EDT)
Message-ID: <20130911.160013.1867055444198020325.davem@davemloft.net>
References: <1378505072-7879-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	shahed.shaikh@qlogic.com, Dept-HSGLinuxNICDev@qlogic.com
To: jitendra.kalsaria@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46565 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757394Ab3IKUAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 16:00:15 -0400
In-Reply-To: <1378505072-7879-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Date: Fri, 6 Sep 2013 18:04:32 -0400

> From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
> 
> drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c: In function 'qlcnic_handle_fw_message':
> drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c:922:4: warning: overflow in implicit constant conversion [-Woverflow]
> 
> Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Applied, thanks.
