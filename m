From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2 v2] net: systemport: checkpatch fixes
Date: Wed,  9 Jul 2014 17:36:45 -0700
Message-ID: <1404952607-10412-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:53843 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753923AbaGJAhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 20:37:34 -0400
Received: by mail-pa0-f46.google.com with SMTP id eu11so10117073pac.33
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2014 17:37:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

These two patches fixes the multiple line alignment issues and
kzalloc on array reported by checkpatch.pl

Thanks!

Florian Fainelli (2):
  net: systemport: align multiple lines correctly
  net: systemport: use kcalloc instead of kzalloc

 drivers/net/ethernet/broadcom/bcmsysport.c | 123 ++++++++++++++---------------
 1 file changed, 61 insertions(+), 62 deletions(-)

-- 
1.9.1
