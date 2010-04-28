From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: sctp: Fix skb_over_panic resulting from multiple
 invalid parameter errors (CVE-2010-1173) (v4)
Date: Wed, 28 Apr 2010 14:23:39 -0700 (PDT)
Message-ID: <20100428.142339.45883821.davem@davemloft.net>
References: <4BD897B6.5040405@hp.com>
	<20100428203059.GG4818@hmsreliant.think-freely.org>
	<4BD89C70.6080406@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, sri@us.ibm.com, linux-sctp@vger.kernel.org,
	eteo@redhat.com, netdev@vger.kernel.org, security@kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59887
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755351Ab0D1VXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 17:23:33 -0400
In-Reply-To: <4BD89C70.6080406@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed, 28 Apr 2010 16:37:04 -0400

> 
> Looks good.
> 
> Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied, thanks Neil and Vlad.
