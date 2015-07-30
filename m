From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] qlcnic: Fix corruption while copying
Date: Wed, 29 Jul 2015 23:57:48 -0700 (PDT)
Message-ID: <20150729.235748.538378358060387571.davem@davemloft.net>
References: <1438170935-9302-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-GELinuxNICDev@qlogic.com
To: shahed.shaikh@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36529 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbbG3G5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 02:57:48 -0400
In-Reply-To: <1438170935-9302-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Date: Wed, 29 Jul 2015 07:55:35 -0400

> From: Shahed Shaikh <shahed.shaikh@qlogic.com>
> 
> Use proper typecasting while performing byte-by-byte copy
> 
> Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>

Applied, thank you.
