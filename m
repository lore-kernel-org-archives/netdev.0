From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 05/11] Removing dead CASSINI_NAPI
Date: Wed, 14 Jul 2010 13:36:25 -0700 (PDT)
Message-ID: <20100714.133625.193700456.davem@davemloft.net>
References: <cover.1279110894.git.siccegge@cs.fau.de>
	<582064a9d6be5cc6f620884ed5120ceb21fdbb12.1279110895.git.siccegge@cs.fau.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, jpirko@redhat.com, joe@perches.com,
	shemminger@vyatta.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	vamos-dev@i4.informatik.uni-erlangen.de
To: siccegge@cs.fau.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48301
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756017Ab0GNUgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 16:36:11 -0400
In-Reply-To: <582064a9d6be5cc6f620884ed5120ceb21fdbb12.1279110895.git.siccegge@cs.fau.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Egger <siccegge@cs.fau.de>
Date: Wed, 14 Jul 2010 14:40:59 +0200

> CASSINI_NAPI doesn't exist in Kconfig, therefore removing all
> references for it from the source code.
> 
> Signed-off-by: Christoph Egger <siccegge@cs.fau.de>

Applied.
