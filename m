From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] cleanup: remove unused member in
 scm_cookie.
Date: Sun, 05 Jul 2009 19:48:28 -0700 (PDT)
Message-ID: <20090705.194828.252263393.davem@davemloft.net>
References: <eb3ff54b0906250742r1507927ai1755e514506bad0d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36977
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755526AbZGFCsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 22:48:21 -0400
In-Reply-To: <eb3ff54b0906250742r1507927ai1755e514506bad0d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Thu, 25 Jun 2009 17:42:19 +0300

> This patch removes an unused member (seq) scm_cookie; besides initialized
> to 0 in the header file, it is not used.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied.
