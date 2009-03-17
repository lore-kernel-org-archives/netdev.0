From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [SK_BUFF]: '< 0' and '>= 0' test on unsigned
Date: Tue, 17 Mar 2009 12:25:11 -0700 (PDT)
Message-ID: <20090317.122511.173615896.davem@davemloft.net>
References: <49BFA8EA.4000702@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, netdev@vger.kernel.org, akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56134
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751932AbZCQTZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 15:25:24 -0400
In-Reply-To: <49BFA8EA.4000702@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Tue, 17 Mar 2009 14:43:06 +0100

> Was this patch missed?

It's in net-next-2.6, I'm not merging all of these trite
off-by-one fixes into net-2.6 so late in the release cycle.
