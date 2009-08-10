From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pcnet32: Read buffer overflow
Date: Sun, 09 Aug 2009 21:49:37 -0700 (PDT)
Message-ID: <20090809.214937.257372338.davem@davemloft.net>
References: <4A7C2B0B.9030508@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pcnet32@verizon.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59240
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751386AbZHJEt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 00:49:28 -0400
In-Reply-To: <4A7C2B0B.9030508@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Fri, 07 Aug 2009 15:24:27 +0200

> An `options[cards_found]' that equals `sizeof(options_mapping)' is already beyond
> the array.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied.
