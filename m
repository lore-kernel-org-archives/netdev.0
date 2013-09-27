From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] qlcnic: Fix register device in FAILED state
 for 82xx.
Date: Fri, 27 Sep 2013 17:26:58 -0400 (EDT)
Message-ID: <20130927.172658.1842447057006493837.davem@davemloft.net>
References: <1380262356-26221-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-HSGLinuxNICDev@qlogic.com
To: sucheta.chakraborty@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50721 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753307Ab3I0V1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 17:27:00 -0400
In-Reply-To: <1380262356-26221-1-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Date: Fri, 27 Sep 2013 02:12:36 -0400

> o Commit 7e2cf4feba058476324dc545e3d1b316998c91e6
>   ("qlcnic: change driver hardware interface mechanism")
>   has overwritten
>   commit b43e5ee76a4320c070cf0fe65cf4927198fbb4d1
>   ("qlcnic: Register device in FAILED state")
> 
> Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

Applied, thanks.
