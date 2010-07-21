From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: remove last uses of __attribute__((packed))
Date: Wed, 21 Jul 2010 14:10:42 -0700 (PDT)
Message-ID: <20100721.141042.97328944.davem@davemloft.net>
References: <1279745998-29694-1-git-send-email-padovan@profusion.mobi>
	<1279745998-29694-2-git-send-email-padovan@profusion.mobi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linville@tuxdriver.com
To: padovan@profusion.mobi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60498
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755648Ab0GUVKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 17:10:25 -0400
In-Reply-To: <1279745998-29694-2-git-send-email-padovan@profusion.mobi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Gustavo F. Padovan" <padovan@profusion.mobi>
Date: Wed, 21 Jul 2010 17:59:58 -0300

> Network code uses the __packed macro instead of __attribute__((packed)).
> 
> Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>

Applied.

John, this might conflict with a wireless-next commit you made
recently, just FYI...
