From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 0/4] 2.6.5-rc2 - epic100 update
Date: Tue, 23 Mar 2004 00:50:21 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040323005021.A1715@electric-eye.fr.zoreil.com>
References: <20040320152109.A31118@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040320152109.A31118@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Sat, Mar 20, 2004 at 03:21:09PM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Schedule:

- epic100-fixup.patch:   opportunistic cleanup
- epic100-napi-00.patch: code shuffling before the move
- epic100-napi-10.patch: rx napi (includes netif_running change)
- epic100-napi-20.patch: minimalistic tx napi

2.6.5-rc2 and 2.6.5-rc2-mm1 contain the same drivers/net/epic100.c
so the patches should apply equally to both.

The driver has been moderately tested. 

Feedback welcome.

--
Ueimor
