From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next 00/15][pull request] 10GbE Intel Wired LAN Driver
 Updates 2017-04-18
Date: Wed, 19 Apr 2017 22:25:16 -0700
Message-ID: <20170420052515.GA77954@ast-mbp.thefacebook.com>
References: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, nhorman@redhat.com,
        sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:32786 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1765920AbdDTFZW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 01:25:22 -0400
Received: by mail-io0-f193.google.com with SMTP id k87so12096355ioi.0
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 22:25:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170418230205.37223-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 18, 2017 at 04:01:50PM -0700, Jeff Kirsher wrote:
> The following are changes since commit 4116c97689b9b1732ac5b68afd922406f9fc842e:
>   Merge branch 'ftgmac100-batch5-features'
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 10GbE

Nothing against this set of commits,
but I saw ixgbe xdp support in there pending for few months.
Now it's gone. What happened?
