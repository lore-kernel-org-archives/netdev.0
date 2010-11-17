From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/10] drivers/net/vxge: Remove unnecessary casts of
 netdev_priv
Date: Wed, 17 Nov 2010 10:44:59 -0800 (PST)
Message-ID: <20101117.104459.115933389.davem@davemloft.net>
References: <cover.1289855436.git.joe@perches.com>
	<5aee4bf89b5baa6e1d32c99be560893925ed2e19.1289855436.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, ramkrishna.vepa@exar.com,
	sivakumar.subramani@exar.com, sreenivasa.honnur@exar.com,
	jon.mason@exar.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41362
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758464Ab0KQSof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 13:44:35 -0500
In-Reply-To: <5aee4bf89b5baa6e1d32c99be560893925ed2e19.1289855436.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon, 15 Nov 2010 13:12:30 -0800

> Signed-off-by: Joe Perches <joe@perches.com>

Applied.

VXGE folks, note that this means any patches you send to me need
to take Joe's changes into account.  If you diff against current
net-next-2.6 you'll be fine.
