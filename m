From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v10] tilegx network driver: initial support
Date: Thu, 07 Jun 2012 13:39:00 -0700 (PDT)
Message-ID: <20120607.133900.1764130639940088009.davem@davemloft.net>
References: <4FCFA312.4020505@tilera.com>
	<20120606.115440.1245419453265419850.davem@davemloft.net>
	<201206072031.q57KV0NG029301@farm-0023.internal.tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, bhutchings@solarflare.com, arnd@arndb.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: cmetcalf@tilera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201206072031.q57KV0NG029301@farm-0023.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Metcalf <cmetcalf@tilera.com>
Date: Fri, 6 Apr 2012 16:42:03 -0400

> Date: Fri, 6 Apr 2012 16:42:03 -0400

You did not commit this file on April 6th.

Please don't use the date emitted by the GIT tools, just
let the email use the natural correct date which is the
one at the time you send the email out.

Otherwise your patch gets misordered as automated tools like
patchwork think this file should go all the way at the back
of the patch queue because of it's old date relative to
other pending patches.
