From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [pktgen script v2 0/2] Add a pktgen sample script of NUMA
 awareness
Date: Mon, 18 Sep 2017 11:06:21 +0200
Message-ID: <20170918110621.355dc215@redhat.com>
References: <1505651798-106642-1-git-send-email-robert.hu@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, tariqt@mellanox.com, kyle.leet@gmail.com,
        netdev@vger.kernel.org, robert.hu@intel.com, brouer@redhat.com
To: Robert Hoo <robert.hu@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46348 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753138AbdIRJG2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 18 Sep 2017 05:06:28 -0400
In-Reply-To: <1505651798-106642-1-git-send-email-robert.hu@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 17 Sep 2017 20:36:36 +0800 Robert Hoo <robert.hu@linux.intel.com> wrote:

> Change log
> v2:
>  Rebased to https://github.com/netoptimizer/network-testing/tree/master/pktgen

Hi Robert,

Thank you for submitting this against my git tree[1]. I skimmed the
patches and they looked okay.  I'll give them a test run, before I
accept them into my tree.

Later I'll synchronize my pktgen scripts/git-tree with the kernel via
regular patches against DaveM's net-next tree[2] (and I'll try to
remember to give you author credit).

[1] https://github.com/netoptimizer/network-testing/tree/master/pktgen
[2] https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/tree/samples/pktgen
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
