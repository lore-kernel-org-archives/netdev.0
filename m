From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] qlcnic: Bug fixes
Date: Thu, 24 Apr 2014 13:31:50 -0400 (EDT)
Message-ID: <20140424.133150.2230330923175964686.davem@davemloft.net>
References: <1398261596-7296-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-HSGLinuxNICDev@qlogic.com
To: shahed.shaikh@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32939 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753419AbaDXRbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 13:31:53 -0400
In-Reply-To: <1398261596-7296-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Date: Wed, 23 Apr 2014 09:59:54 -0400

> This patch series contains following fixes -
> 
> * Fix memory leak caused because of issuing mailbox
>   command which can not wait for its completion.
> * Reset firmware API lock which might be in inconsistent state.
> 
> Please apply this series to net.

Series applied, thanks.
