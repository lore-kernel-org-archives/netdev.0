From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] nfp: SR-IOV ndos support
Date: Fri, 25 Aug 2017 19:25:14 -0700 (PDT)
Message-ID: <20170825.192514.1737298151611853692.davem@davemloft.net>
References: <20170825043150.375-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39612 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751453AbdHZCZP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 22:25:15 -0400
In-Reply-To: <20170825043150.375-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Thu, 24 Aug 2017 21:31:48 -0700

> This set adds basic SR-IOV including setting/getting VF MAC addresses,
> VLANs, link state and spoofcheck settings.  It is wired up for both
> vNICs and representors (note: ip link will not report VF settings on
> VF/PF representors because they are not linked to the PF PCI device).
> 
> Pablo and team add the basic implementation, Simon and Dirk follow
> up with the representor plumbing.

Series applied, thanks.
