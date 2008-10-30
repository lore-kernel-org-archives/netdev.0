From: David Miller <davem@davemloft.net>
Subject: Re: question: emulate_large_send_offload
Date: Thu, 30 Oct 2008 14:37:47 -0700 (PDT)
Message-ID: <20081030.143747.163113057.davem@davemloft.net>
References: <4909F4E1.3070304@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
To: hummerbliss@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57582
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753653AbYJ3ViN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 17:38:13 -0400
In-Reply-To: <4909F4E1.3070304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saikiran Madugula <hummerbliss@gmail.com>
Date: Thu, 30 Oct 2008 17:54:41 +0000

netdev is the proper mailing list for code and technical
networking discussions, linux-net is for simpler user
questions such as "how do I configure a bridge with 3
interfaces under Linux"

netdev added to CC:

> Any particular reason emulate_large_send_offload call is still present in the
> loopback_xmit (drivers/net/loopback.c)? It looks like the function has been
> removed recently (git commit 7447ef63cf2dfdc444f4c72ae13f604350b2e25f).
> 
> Saikiran.
> Please CC me as I am not on the list.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-net" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
