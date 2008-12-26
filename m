From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] gigaset: ifdef cleanup
Date: Fri, 26 Dec 2008 01:22:48 -0800 (PST)
Message-ID: <20081226.012248.204332547.davem@davemloft.net>
References: <20081223-patch-00.tilman@imap.cc>
	<200812230927.mBN9ROEn028596@mail.pxnet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: tilman@imap.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34048
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752949AbYLZJWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 04:22:46 -0500
In-Reply-To: <200812230927.mBN9ROEn028596@mail.pxnet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>
Date: Tue, 23 Dec 2008 10:27:24 +0100

> Remove unnecessary #ifdef-s and #if-0-ed code sections.
> 
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>

Applied.
