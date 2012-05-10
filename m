From: alex.bluesman.smirnov@gmail.com
Subject: [PATCH 0/2 net] 6lowpan fixes
Date: Thu, 10 May 2012 17:22:41 +0400
Message-ID: <4fabc165.9208cc0a.4de8.ffff920d@mx.google.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:50814 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754485Ab2EJNXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 09:23:50 -0400
Received: by bkcji2 with SMTP id ji2so1280917bkc.19
        for <netdev@vger.kernel.org>; Thu, 10 May 2012 06:23:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

this patch set contains 2 fixes for the 6lowpan module. Please find detailed
description in the patch headers.

With best regards,
Alex

8<--

The following changes since commit 4b31b26441fb3c5f1e61ee13832358c09f8ca12d:

  6lowpan: duplicate definition of IEEE802154_ALEN (2012-04-26 13:02:33 +0400)

are available in the git repository at:
  http://github.com/linux-wsn/kernel.git 6lowpan_dev

Alexander Smirnov (2):
      6lowpan: add missing pskb_may_pull() check
      6lowpan: fix hop limit compression

 net/ieee802154/6lowpan.c |    3 +++

From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH 0/2 net] 6lowpan fixes
In-Reply-To: 
