From: Thomas Gleixner <tglx@linutronix.de>
Subject: [PATCH] net: Make devnet_rename_seq static
Date: Tue, 23 Jul 2013 16:05:15 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1307231559570.4089@ionos.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:46729 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757277Ab3GWOFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 10:05:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No users outside net/core/dev.c.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
