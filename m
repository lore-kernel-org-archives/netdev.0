From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] via_rhine: Use netdev_<level> and pr_<level>
Date: Sun, 17 Apr 2011 17:56:55 -0700 (PDT)
Message-ID: <20110417.175655.63020877.davem@davemloft.net>
References: <4DAA12C0.7030106@gmail.com>
	<cover.1302998994.git.joe@perches.com>
	<15b0ca3fc5ba6a16b207fb32b0c2e3c809f376d1.1302998994.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mr.nuke.me@gmail.com, rl@hellgate.ch, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33759
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752320Ab1DRA5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:57:30 -0400
In-Reply-To: <15b0ca3fc5ba6a16b207fb32b0c2e3c809f376d1.1302998994.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sat, 16 Apr 2011 17:15:25 -0700

> Use the more current logging styles.
> 
> Add #define DEBUG to make netdev_dbg always active.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
