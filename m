From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 0/5 v2] SCTP updates for net-next-2.6
Date: Wed, 27 Apr 2011 13:20:18 -0700 (PDT)
Message-ID: <20110427.132018.189724779.davem@davemloft.net>
References: <4DB7C73D.3000406@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37971
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755637Ab1D0UUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 16:20:52 -0400
In-Reply-To: <4DB7C73D.3000406@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Wed, 27 Apr 2011 15:35:25 +0800

> Hi David
> 
> Here is a set of SCTP patches for net-next-2.6, the last part
> from vlad's lksctp-dev tree, update SCTP IPv6 routing and IPSec
> issues. Please apply.
> 
> Changelog:
>   - redo the intermediate builds test and function test.
>   - remove useless ->dst_saddr member of sctp_pf
>   - merge some fix for original patch

Applied, thanks!
