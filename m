From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/6] qlcnic: Add ethtool statistics for board
 temperature.
Date: Tue, 30 Jul 2013 19:27:23 -0700 (PDT)
Message-ID: <20130730.192723.699554467882059430.davem@davemloft.net>
References: <cover.1375244889.git.himanshu.madhani@qlogic.com>
	<6a88678cfe46e0e4f639e8f80834dd3e4b46fdd1.1375244889.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: himanshu.madhani@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44936 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751892Ab3GaC1Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 22:27:24 -0400
In-Reply-To: <6a88678cfe46e0e4f639e8f80834dd3e4b46fdd1.1375244889.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Date: Tue, 30 Jul 2013 21:54:19 -0400

> From: Himanshu Madhani <himanshu.madhani@qlogic.com>
> 
> o Added ethtool statistics to display adapter board
>   temperature.
> 
> Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>

A statistic is a count of events, this is not such a thing.

Furthermore, even if this fit the model of statistical events,
there is no way for the user to know what units the value is
in.

Sorry I'm not applying these patches.
