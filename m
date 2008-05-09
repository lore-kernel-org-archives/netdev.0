From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next-2.6 1/3] [SCTP]: Bring SCTP_DELAYED_ACK socket
 option into API compliance
Date: Fri, 09 May 2008 15:15:02 -0700 (PDT)
Message-ID: <20080509.151502.215470212.davem@davemloft.net>
References: <1210360481-16599-1-git-send-email-vladislav.yasevich@hp.com>
	<1210360566-16661-1-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net, yjwei@cn.fujitsu.com
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42489
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753531AbYEIWPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 18:15:09 -0400
In-Reply-To: <1210360566-16661-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri,  9 May 2008 15:16:04 -0400

> Brings delayed_ack socket option set/get into line with the latest ietf
> socket extensions API draft, while maintaining backwards compatibility.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
