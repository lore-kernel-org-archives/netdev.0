From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] Preparation for VLAN_TAG_PRESENT cleanup
Date: Tue, 03 Jan 2017 22:23:32 -0500 (EST)
Message-ID: <20170103.222332.1319598673818705870.davem@davemloft.net>
References: <cover.1483487429.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36884 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935135AbdADDeX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 22:34:23 -0500
In-Reply-To: <cover.1483487429.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


By submitted these in sections, but all at once, you are subverting
my requirement to submit only small self contained patch series.

Please do not do this.

The whole point is to not have a lot of patches in flight for one
thing for people to review at one time.  Contributors can review
more easily small, easily digestable, pieces.

Start over, and only submit small numbers of patches at one time.  Do
not submit new patches until the first series has been processed.

Thank you.
