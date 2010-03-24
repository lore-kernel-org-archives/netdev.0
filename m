From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] gianfar: fix undo of reserve()
Date: Wed, 24 Mar 2010 13:21:07 -0700 (PDT)
Message-ID: <20100324.132107.69971793.davem@davemloft.net>
References: <A6A1774AFD79E346AE6D49A33CB294530DC19FC4@EX-BE-017-SFO.shared.themessagecenter.com>
	<20100324.114759.200629461.davem@davemloft.net>
	<A6A1774AFD79E346AE6D49A33CB294530DC1A006@EX-BE-017-SFO.shared.themessagecenter.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ben@bigfootnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58443
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751283Ab0CXUUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 16:20:44 -0400
In-Reply-To: <A6A1774AFD79E346AE6D49A33CB294530DC1A006@EX-BE-017-SFO.shared.themessagecenter.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ben Menchaca (ben@bigfootnetworks.com)" <ben@bigfootnetworks.com>
Date: Wed, 24 Mar 2010 13:13:22 -0700

> I would definitely prefer getting some modern-ish kernel time on it.
> If needed, I can probably move our board forward to -next for a bit.

If anyone can test this on a current kernel that would be
enough for me.
