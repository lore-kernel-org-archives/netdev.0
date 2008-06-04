From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/6] SCTP: Correctly implement Fast Recovery cwnd
 manipulations.
Date: Wed, 04 Jun 2008 12:38:51 -0700 (PDT)
Message-ID: <20080604.123851.195184149.davem@davemloft.net>
References: <1212603951-24932-1-git-send-email-vladislav.yasevich@hp.com>
	<1212603951-24932-4-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47515
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753970AbYFDTiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 15:38:51 -0400
In-Reply-To: <1212603951-24932-4-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed,  4 Jun 2008 14:25:48 -0400

> Correctly keep track of Fast Recovery state and do not reduce
> congestion window multiple times during sucht state.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Tested-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Applied.
