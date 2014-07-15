From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] hso: remove unused workqueue
Date: Mon, 14 Jul 2014 19:27:51 -0700 (PDT)
Message-ID: <20140714.192751.860546525235995890.davem@davemloft.net>
References: <1405332530-2507-1-git-send-email-olivier@sobrie.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: olivier@sobrie.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37437 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753241AbaGOC1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 22:27:53 -0400
In-Reply-To: <1405332530-2507-1-git-send-email-olivier@sobrie.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Olivier Sobrie <olivier@sobrie.be>
Date: Mon, 14 Jul 2014 12:08:49 +0200

> The workqueue "retry_unthrottle_workqueue" is not scheduled anywhere
> in the code. So, remove it.
> 
> Signed-off-by: Olivier Sobrie <olivier@sobrie.be>

Applied.
