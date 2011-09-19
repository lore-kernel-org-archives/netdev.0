From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: wireless build errors on latest net-next
Date: Mon, 19 Sep 2011 06:22:29 +0200
Message-ID: <1316406149.2521.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63094 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736Ab1ISEWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 00:22:36 -0400
Received: by wwf22 with SMTP id 22so7420257wwf.1
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2011 21:22:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel: arch/x86/boot/bzImage is ready  (#299)
  Building modules, stage 2.
  MODPOST 1778 modules
ERROR: "iwl_dump_fh" [drivers/net/wireless/iwlwifi/iwlagn.ko] undefined!
ERROR: "iwl_dump_csr" [drivers/net/wireless/iwlwifi/iwlagn.ko]
undefined!
make[1]: *** [__modpost] Erreur 1
make: *** [modules] Erreur 2
