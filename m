From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] Phonet: declare headers
Date: Tue, 30 Sep 2008 02:59:57 -0700 (PDT)
Message-ID: <20080930.025957.261573022.davem@davemloft.net>
References: <1222272700-28232-3-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60962
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751838AbYI3KAI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2008 06:00:08 -0400
In-Reply-To: <1222272700-28232-3-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
Date: Wed, 24 Sep 2008 19:11:40 +0300

> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Applied.

I took a look and noticed that if_phonet.h needs some top-level
ifdef multiple inclusion protection.
