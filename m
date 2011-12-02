From: Roland Dreier <roland@kernel.org>
Subject: Re: [PATCH] infiniband: addr: Avoid unnecessary neigh lookup.
Date: Fri, 2 Dec 2011 15:18:00 -0800
Message-ID: <CAL1RGDU8=G_TKRirxm6pMni3H3a-FbvDz+pzG_oaZo-LYBQ0bg@mail.gmail.com>
References: <20111202.145525.1679807360238725746.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog103.obsmtp.com ([74.125.245.74]:48137 "HELO
	na3sys010aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752118Ab1LBXSW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 18:18:22 -0500
Received: by mail-bw0-f52.google.com with SMTP id 17so581062bke.39
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2011 15:18:21 -0800 (PST)
In-Reply-To: <20111202.145525.1679807360238725746.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> So if it's OK with you I'd like to merge this stuff directly in the
> net-next tree after getting your ACK on each patch.

Sure, that's fine, and for this particular patch:

Acked-by: Roland Dreier <roland@purestorage.com>
