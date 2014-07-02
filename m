From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/2] net: systemport: checkpatch fixes
Date: Wed,  2 Jul 2014 10:54:57 -0700
Message-ID: <1404323699-12342-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:32946 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755983AbaGBRzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 13:55:19 -0400
Received: by mail-ie0-f178.google.com with SMTP id rl12so525217iec.9
        for <netdev@vger.kernel.org>; Wed, 02 Jul 2014 10:55:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

These two patches fixes "CHECK" warnings issued by checkpatch.pl.

Thanks!

Florian Fainelli (2):
  net: systemport: align multiple lines correctly
  net: systemport: use kcalloc instead of kzalloc

 drivers/net/ethernet/broadcom/bcmsysport.c | 113 ++++++++++++++---------------
 1 file changed, 56 insertions(+), 57 deletions(-)

-- 
1.9.1
