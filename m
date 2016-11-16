From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V6 0/9] liquidio CN23XX VF support
Date: Tue, 15 Nov 2016 22:25:59 -0500 (EST)
Message-ID: <20161115.222559.809414338023708156.davem@davemloft.net>
References: <1479167687-9904-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rvatsavayi@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35746 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932203AbcKPD0H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 22:26:07 -0500
In-Reply-To: <1479167687-9904-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Date: Mon, 14 Nov 2016 15:54:38 -0800

> Following is the V6 patch series for adding VF support on
> CN23XX devices. This version addressed:
> 1) Your concern for ordering of local variable declarations
>    from longest to shortest line.
> 2) Removed module parameters max_vfs, num_queues_per_{p,v}f.
> 3) Minor changes for fixing new checkpatch script related 
>    errors on pre-existing driver.
> 4) Fixed compilation issues when CONFIG_PCI_IOV/CONFIG_PCI_ATS
>    options are disabled.
> 5) Modified qualifiers for printing mac addresses with pM format.
> 
> I will post remaining VF patches soon after this patchseries is
> applied. Please apply patches in the following order as some of
> the patches depend on earlier patches.

Series applied, thanks.
