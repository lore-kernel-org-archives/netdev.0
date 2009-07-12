From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: remove unused exports
Date: Sun, 12 Jul 2009 14:17:20 -0700 (PDT)
Message-ID: <20090712.141720.17307883.davem@davemloft.net>
References: <1247250726.29747.15.camel@johannes.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56741
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752090AbZGLVRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jul 2009 17:17:16 -0400
In-Reply-To: <1247250726.29747.15.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Fri, 10 Jul 2009 20:32:06 +0200

> I added those myself in commits b4ff4f04 and 84659eb5,
> but I see no reason now why they should be exported,
> only generic netlink uses them which cannot be modular.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

Applied.
