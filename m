From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v1 2/4] nvmet-rdma: use generic inet_pton_with_scope
Date: Tue, 28 Feb 2017 08:35:10 -0800
Message-ID: <20170228163510.GB26480@infradead.org>
References: <1488217164-9221-1-git-send-email-sagi@grimberg.me>
 <1488217164-9221-3-git-send-email-sagi@grimberg.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nvme@lists.infradead.org, target-devel@vger.kernel.org,
        netdev@vger.kernel.org
To: Sagi Grimberg <sagi@grimberg.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:40266 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751835AbdB1QfW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 11:35:22 -0500
Content-Disposition: inline
In-Reply-To: <1488217164-9221-3-git-send-email-sagi@grimberg.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please add a changelog and mention that this adds IPv6 support.

Otherwise looks fine:

Reviewed-by: Christoph Hellwig <hch@lst.de>
