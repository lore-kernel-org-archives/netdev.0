From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] netfilter : xt_u32 bug correction
Date: Tue, 14 Aug 2007 14:17:33 +0200
Message-ID: <20070814141733.1a0e37f8.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, jengelh@gmx.de
To: "kaber@trash.net" <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:41724 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754952AbXHNMRf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 08:17:35 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all

This applies to net-2.6 (so should be forwared to Linus for 2.6.23 inclusion ?)

Thank you

[PATCH] netfilter : xt_u32 bug correction

An extraneous ";" makes xt_u32 match useless

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
