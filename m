From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next PATCH 0/4] Updates for samples/pktgen
Date: Wed, 1 Nov 2017 09:28:53 -0700
Message-ID: <20171101162852.vtba4qqxr34grtor@ast-mbp>
References: <150953283424.29671.6809291616813585256.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Robert Olsson <robert@herjulf.se>,
        robert.hu@intel.com, pabeni@redhat.com, kafai@fb.com,
        tariqt@mellanox.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:55829 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752363AbdKAQ2x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 12:28:53 -0400
Received: by mail-pg0-f66.google.com with SMTP id 15so2510754pgc.12
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 09:28:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <150953283424.29671.6809291616813585256.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 01, 2017 at 11:41:04AM +0100, Jesper Dangaard Brouer wrote:
> This patchset updates samples/pktgen and synchronize with changes
> maintained in https://github.com/netoptimizer/network-testing/
> 
> Features wise Robert Hoo <robert.hu@intel.com> added support for
> detecting and determining dev NUMA node IRQs, and added a new script
> named pktgen_sample06_numa_awared_queue_irq_affinity.sh that use these
> features.
> 
> Cleanup remove last of the old sample files, as IPv6 is covered by
> existing sample code.

Looks nice. Thanks for doing this work.

Acked-by: Alexei Starovoitov <ast@kernel.org>
