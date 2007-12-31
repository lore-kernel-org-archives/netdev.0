From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25] [IPV4] Remove unused multipath cached
 routing defintion in net/flow.h
Date: Mon, 31 Dec 2007 04:29:22 -0800 (PST)
Message-ID: <20071231.042922.37372731.davem@davemloft.net>
References: <eb3ff54b0712310315l4df16c6fye0bf2a82505d20be@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47191
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752209AbXLaM3X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 07:29:23 -0500
In-Reply-To: <eb3ff54b0712310315l4df16c6fye0bf2a82505d20be@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Mon, 31 Dec 2007 13:15:19 +0200

> The FLOWI_FLAG_MULTIPATHOLDROUTE definition in include/net/flow.h is an unused
>   definition. It belongs to IPV4 multipath cached routing support,
>    which has been dropped recently for 2.6.23 kernel (July 2007).

Yep.

> http://www.linux-foundation.org/en/Net:Network_Overview

Why do you keep listing this URL?  Is this your signature? :-/

I don't think the 1000 or so folks on this list need to see
that same URL every time you post a patch, thanks.

> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Patch applied, thank you.
