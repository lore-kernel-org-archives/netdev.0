From: David Miller <davem@davemloft.net>
Subject: Re: PF_RING for n/w traffic more than 1 Gbps
Date: Mon, 22 Jun 2009 00:28:34 -0700 (PDT)
Message-ID: <20090622.002834.240476749.davem@davemloft.net>
References: <e31d15d70906220020y70f0daf9k4650d96c402fdf7a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: vishwakarma.deepak@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50934
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751002AbZFVH2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 03:28:30 -0400
In-Reply-To: <e31d15d70906220020y70f0daf9k4650d96c402fdf7a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Deepak Vishwakarma <vishwakarma.deepak@gmail.com>
Date: Mon, 22 Jun 2009 12:50:11 +0530

> PF_RING kernel patch not optimized for traffic handling more than 1
> Gbps. I am facing packet overrun over 1 Gbps with linux 2.6.30 patched
> with PF_RING.
> 
> Does any one has achieved more than 2-3 Gbps packet handling with or
> without PF_RING.

You'll have more luck with this question on the networking developer
list, netdev@vger.kernel.org, which has been CC:'d
