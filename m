From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 7/8] sctp: Allow bindx_del to accept 0 port
Date: Tue, 19 Apr 2011 21:47:41 -0700 (PDT)
Message-ID: <20110419.214741.13766667.davem@davemloft.net>
References: <4DAD18AB.3040401@cn.fujitsu.com>
	<4DAD1A47.5080007@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54831
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751847Ab1DTEsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 00:48:15 -0400
In-Reply-To: <4DAD1A47.5080007@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Tue, 19 Apr 2011 13:14:47 +0800

> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> 
> We allow 0 port when adding new addresses.  It only
> makes sence to allow 0 port when removing addresses.
> When removing the currently bound port will be used
> when the port in the address is set to 0.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Applied.
