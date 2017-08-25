From: Stefano Brivio <sbrivio@redhat.com>
Subject: how to submit fixes for i40e/i40evf?
Date: Fri, 25 Aug 2017 22:52:15 +0200
Message-ID: <20170825225215.35fc6b59@elisabeth>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
To: "David S. Miller" <davem@davemloft.net>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46606 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932586AbdHYUwX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Aug 2017 16:52:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

As I'm currently preparing another fix for i40e, and the last one I
submitted has been stuck for about two weeks now, I would like to ask
some details about the process to submit fixes for i40e/i40evf drivers,
before I do something wrong again.

Do all the patches have to go through Intel's patchwork, no matter
what's the perceived severity of the issue? Should I still submit them
to netdev anyway?

Which trees should I check before submitting a patch? Is it enough to
check the master branch of jkirsher/net-queue.git and
jkirsher/next-queue.git?

Once patches reach Intel's patchwork, will they need to wait for some
kind of periodically scheduled pull request process?

I don't know if a process is actually defined at this level of detail,
but still I feel it's wrong that an obvious fix for a potential crash is
waiting in some sort of limbo for 10 days now. Sure, worse things
happen in the world, but I can't understand what this patch is waiting
for.

Any answer is appreciated. Thanks,
