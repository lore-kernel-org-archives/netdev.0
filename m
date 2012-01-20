From: Bart Van Assche <bvanassche@acm.org>
Subject: Recent RCU changes in the networking code
Date: Fri, 20 Jan 2012 17:35:54 +0000
Message-ID: <CAO+b5-oqBNyXy+-a712VrnhSteVSPk8J5Om95E-ZQHtJBVgJAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39553 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754914Ab2ATRf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2012 12:35:56 -0500
Received: by wgbed3 with SMTP id ed3so649444wgb.1
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2012 09:35:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

As far as I can see commit cf778b00e96df6d64f8e21b8395d1f8a859ecdc7 is
a fix for commit a9b3cd7f323b2e57593e7215362a7b02fc933e3a, the latter
has been included in 3.2 but the former has not yet been sent to
stable@vger.kernel.org. Shouldn't commit cf778b0 be sent to stable
such that it gets included in the v3.2.x series ?

Thanks,

Bart.

See also:
[1] http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commit;h=cf778b00e96df6d64f8e21b8395d1f8a859ecdc7
[2] http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commit;h=a9b3cd7f323b2e57593e7215362a7b02fc933e3a
