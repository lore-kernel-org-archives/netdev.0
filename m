From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: stable inclusion request for "inet: fix potential deadlock in
 reqsk_queue_unlink()"
Date: Wed, 14 Oct 2015 09:43:07 -0700
Message-ID: <1444840987.4166.35.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34629 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126AbbJNQnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 12:43:10 -0400
Received: by payp3 with SMTP id p3so11054737pay.1
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 09:43:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

Please add the following patch for next 4.1 release, as the bug is
hurting many users of 4.1.10

http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=83fccfc3940c4a2db90fd7e7079f5b465cd8c6af


This is not yet seen on
http://patchwork.ozlabs.org/bundle/davem/stable/?state=*


Thanks !
