From: "Ming Lei" <tom.leiming@gmail.com>
Subject: BUG: iwlwifi build failed
Date: Tue, 22 Jul 2008 12:43:03 +0800
Message-ID: <d82e647a0807212143r2f598a59y76a79fd9bb8f17@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.191]:51034 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223AbYGVEnF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 00:43:05 -0400
Received: by fk-out-0910.google.com with SMTP id 18so1156434fkq.5
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 21:43:03 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 93ded9b8fd42abe2c3607097963d8de6ad9117eb
Merge: 6d52dcb... f756cbd...
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Mon Jul 21 15:42:20 2008 -0700
=====================================

drivers/net/wireless/iwlwifi/iwl-led.c: In function 'iwl_led_brightness_set':
drivers/net/wireless/iwlwifi/iwl-led.c:198: error: 'led_type_str'
undeclared (first use in this function)
drivers/net/wireless/iwlwifi/iwl-led.c:198: error: (Each undeclared
identifier is reported only once
drivers/net/wireless/iwlwifi/iwl-led.c:198: error: for each function
it appears in.)
make[4]: *** [drivers/net/wireless/iwlwifi/iwl-led.o] Error 1
make[3]: *** [drivers/net/wireless/iwlwifi] Error 2
make[2]: *** [drivers/net/wireless] Error 2
make[1]: *** [drivers/net] Error 2
make: *** [drivers] Error 2


-- 
Lei Ming
