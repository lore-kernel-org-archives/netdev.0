From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v2] mlxsw: convert to pci_alloc_irq_vectors
Date: Thu, 6 Apr 2017 14:59:19 +0200
Message-ID: <20170406125919.GA2064@nanopsycho>
References: <20170406122303.30758-1-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@mellanox.com, idosch@mellanox.com, netdev@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:36281 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932358AbdDFM70 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 08:59:26 -0400
Received: by mail-it0-f52.google.com with SMTP id 19so4273653itj.1
        for <netdev@vger.kernel.org>; Thu, 06 Apr 2017 05:59:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170406122303.30758-1-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Apr 06, 2017 at 02:23:03PM CEST, hch@lst.de wrote:
>Trivial conversion as only one vector is supported, but at least we
>lose the useless msix_entry member in the per-device structure.
>
>Signed-off-by: Christoph Hellwig <hch@lst.de>

Acked-by: Jiri Pirko <jiri@mellanox.com>
