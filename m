From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next (repost)] nfp: Use PCI_DEVICE_ID_NETRONOME_NFP*
 defines
Date: Fri, 17 Feb 2017 10:26:20 -0800
Message-ID: <20170217102620.69d48e9f@cakuba.netronome.com>
References: <1487318274-17216-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33401 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934053AbdBQS0Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 13:26:24 -0500
Received: by mail-pf0-f182.google.com with SMTP id c73so15289010pfb.0
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2017 10:26:23 -0800 (PST)
In-Reply-To: <1487318274-17216-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 17 Feb 2017 08:57:54 +0100, Simon Horman wrote:
> Use PCI_DEVICE_ID_NETRONOME_NFP*, defined in linux/pci_ids.h,
> rather than replicating the same values in the NFP driver.
> 
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Perhaps unnecessary and obvious but this was:

Acked-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Thanks Simon!
