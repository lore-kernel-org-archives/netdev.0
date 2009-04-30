From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH mmotm] mm: alloc_large_system_hash check order
Date: Wed, 29 Apr 2009 17:25:31 -0700 (PDT)
Message-ID: <20090429.172531.38936655.davem@davemloft.net>
References: <Pine.LNX.4.64.0904292151350.30874@blonde.anvils>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
To: hugh@veritas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45286
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753090AbZD3AZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 20:25:38 -0400
In-Reply-To: <Pine.LNX.4.64.0904292151350.30874@blonde.anvils>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hugh Dickins <hugh@veritas.com>
Date: Wed, 29 Apr 2009 22:09:48 +0100 (BST)

> Cc'ed DaveM and netdev, just in case they're surprised it was asking for
> so much, or disappointed it's not getting as much as it was asking for.

This is basically what should be happening, thanks for the note.
