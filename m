From: David Miller <davem@davemloft.net>
Subject: Re: [next-net 00/19][pull request] Intel Wired LAN Driver Updates
 2017-02-02
Date: Fri, 03 Feb 2017 16:28:46 -0500 (EST)
Message-ID: <20170203.162846.1286497539881724174.davem@davemloft.net>
References: <20170203072553.168372-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54040 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752365AbdBCV2s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 16:28:48 -0500
In-Reply-To: <20170203072553.168372-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Pretty sloppy submission Jeff.

First of all, things are getting backlogged way too much.  19 patches
is too large, you need to keep it closer down to 10 and the very very
low teens.  You need to send me pull requests more often so that this
does not happen.

Second of all, all of your Subjects are messed up and have "queue"
misspelled and things like this.

Finally, there is nothing to even pull at the URL you provided:

[davem@dhcp-10-15-49-210 net-next]$ git pull --no-ff git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master
>From git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue
 * branch            master     -> FETCH_HEAD
Already up-to-date.
