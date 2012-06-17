From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] usbnet: handle remote wakeup asap
Date: Sun, 17 Jun 2012 16:22:33 -0700 (PDT)
Message-ID: <20120617.162233.868029041800646826.davem@davemloft.net>
References: <1339561217-18151-1-git-send-email-ming.lei@canonical.com>
	<1339561217-18151-4-git-send-email-ming.lei@canonical.com>
	<CACVXFVMO0Z23kW59YRyfbVFu77vG6_yAMxAhOXk619V0dhF7Fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, oneukum@suse.de,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	stable@vger.kernel.org
To: ming.lei@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37963 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966Ab2FQXWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jun 2012 19:22:34 -0400
In-Reply-To: <CACVXFVMO0Z23kW59YRyfbVFu77vG6_yAMxAhOXk619V0dhF7Fw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ming Lei <ming.lei@canonical.com>
Date: Fri, 15 Jun 2012 10:22:16 +0800

> David, sorry, the 'GFP_ATOMIC' above should be 'flags', so could
> you take the fixed version from attachment? Or could you do it by
> your self?

You are rushing this patch submission if you are finding such
errors right after you post the patch.

Take your time and properly audit your work, then resubmit your
entire series again once it is really ready.
