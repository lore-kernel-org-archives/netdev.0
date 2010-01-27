From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] ipv6: Fix possible NULL dereference in icmp6_dst_alloc
Date: Wed, 27 Jan 2010 12:17:46 +0000
Message-ID: <20100127121746.GA15611@ff.dom.local>
References: <20100127095952.GA11635@ff.dom.local> <20100127.021424.263649631.davem@davemloft.net> <20100127103417.GA15206@ff.dom.local> <20100127.030416.179345234.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, djohnson@starentnetworks.com,
	sakkiped@starentnetworks.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:55546 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056Ab0A0MRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 07:17:53 -0500
Received: by fxm20 with SMTP id 20so1487820fxm.21
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2010 04:17:51 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100127.030416.179345234.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 27, 2010 at 03:04:16AM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Wed, 27 Jan 2010 10:34:17 +0000
> 
> > (Btw, maybe it's a sign this might be more readable?)
> 
> I welcome suggests that, tree wide, would make this harder
> to misinterpret.

If there is nothing better I still think this patch is right, except
better subject (Fix impossible NULL dereference in ... ;-).

Jarek P.
