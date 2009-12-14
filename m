From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix userspace RTM_NEWLINK notifications.
Date: Sun, 13 Dec 2009 19:46:05 -0800 (PST)
Message-ID: <20091213.194605.59666989.davem@davemloft.net>
References: <m1fx7fmgyk.fsf@fess.ebiederm.org>
	<1260756336.4041.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org, stable@kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50704
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754479AbZLNDqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2009 22:46:04 -0500
In-Reply-To: <1260756336.4041.3.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Mon, 14 Dec 2009 03:05:36 +0100

> the POST_INIT and UNREGISTER_BATCH are not 2.6.32 features. They are
> 2.6.33 features and thus you need to create a separate patch for -stable
> if you wanna fix the /proc access issue.

Eric, please give me a suitable backport for -stable.

Thanks.
