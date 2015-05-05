From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mpls: Move reserved label definitions
Date: Tue, 05 May 2015 19:41:06 -0400 (EDT)
Message-ID: <20150505.194106.1402447017139921766.davem@davemloft.net>
References: <1430841990-2828702-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58037 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316AbbEEXlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:41:07 -0400
In-Reply-To: <1430841990-2828702-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 5 May 2015 09:06:30 -0700

> Move to include/uapi/linux/mpls.h to be externally visibile.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

If we want to propagate this into the user header file, we should
do so ASAP, so I've applied this to 'net' instead of 'net-next'.

Thanks Tom.
