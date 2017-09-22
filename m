From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [pktgen script v2 0/2] Add a pktgen sample script of NUMA
 awareness
Date: Fri, 22 Sep 2017 16:06:54 +0200
Message-ID: <20170922160654.08ae8961@redhat.com>
References: <1505651798-106642-1-git-send-email-robert.hu@linux.intel.com>
        <20170918110621.355dc215@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, tariqt@mellanox.com, kyle.leet@gmail.com,
        netdev@vger.kernel.org, robert.hu@intel.com, brouer@redhat.com
To: Robert Hoo <robert.hu@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59474 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752245AbdIVOHC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 22 Sep 2017 10:07:02 -0400
In-Reply-To: <20170918110621.355dc215@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 Sep 2017 11:06:21 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> On Sun, 17 Sep 2017 20:36:36 +0800 Robert Hoo <robert.hu@linux.intel.com> wrote:
> 
> > Change log
> > v2:
> >  Rebased to https://github.com/netoptimizer/network-testing/tree/master/pktgen  
> 
> Hi Robert,
> 
> Thank you for submitting this against my git tree[1]. I skimmed the
> patches and they looked okay.  I'll give them a test run, before I
> accept them into my tree.
> 
> Later I'll synchronize my pktgen scripts/git-tree with the kernel via
> regular patches against DaveM's net-next tree[2] (and I'll try to
> remember to give you author credit).
> 
> [1] https://github.com/netoptimizer/network-testing/tree/master/pktgen
> [2] https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/tree/samples/pktgen

FYI, I've applied and pushed these patches to my tree.
 https://github.com/netoptimizer/network-testing/commits?author=robert-hoo
 https://github.com/netoptimizer/network-testing/commit/1b9b4b797a4f112
 https://github.com/netoptimizer/network-testing/commit/65efc2352f63dde
 https://github.com/netoptimizer/network-testing/commit/54eb5178aaf4031

I fixed the description a bit, and only made one simple change:
 https://github.com/netoptimizer/network-testing/commit/9ff58568b3f8c91

Thanks for working on improving the pktgen scripts :-)
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
