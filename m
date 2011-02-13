From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: undo_retrans counter fixes
Date: Sun, 13 Feb 2011 11:07:45 -0800 (PST)
Message-ID: <20110213.110745.241447405.davem@davemloft.net>
References: <AANLkTikh4YXzJGgTWsTjpz6BczrfSGYD_qSg3WWmKrs9@mail.gmail.com>
	<alpine.DEB.2.00.1102081110050.26191@melkinpaasi.cs.helsinki.fi>
	<AANLkTiktBOC_26Aox8LVjPCTh33Gztd7RvA-kQVdih=h@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46761
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754738Ab1BMTHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Feb 2011 14:07:09 -0500
In-Reply-To: <AANLkTiktBOC_26Aox8LVjPCTh33Gztd7RvA-kQVdih=h@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Fri, 11 Feb 2011 16:10:50 -0800

> Dave/Ilpo: can this patch get applied or it needs more
> clarification/justification? Thanks.

Ilpo and you are still discussing the merits of doing the
checks in one place or another, and whether this is the best
place to handle this issue.

I also see no rush in applying a patch for an obscure hard to
trigger issue that has been present for such a long time.

It's in the patchwork queue, so don't worry it won't get lost ;)
