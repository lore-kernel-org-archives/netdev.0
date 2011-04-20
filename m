From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/8 v2] sctp: delete unused macro
 definition of sctp_chunk_is_control
Date: Tue, 19 Apr 2011 21:47:02 -0700 (PDT)
Message-ID: <20110419.214702.27789384.davem@davemloft.net>
References: <4DAD18AB.3040401@cn.fujitsu.com>
	<4DAD1915.70503@cn.fujitsu.com>
	<4DAD1B61.6080504@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54807
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750843Ab1DTErh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 00:47:37 -0400
In-Reply-To: <4DAD1B61.6080504@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Tue, 19 Apr 2011 13:19:29 +0800

> From: Shan Wei <shanwei@cn.fujitsu.com>
> 
> The macro never be used.
> And if needed, can use !sctp_chunk_is_data instead of.
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Applied.
