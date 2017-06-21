From: "Steve Wise" <swise@opengridcomputing.com>
Subject: RE: [PATCH rdma-next 06/19] RDMA/netlink: Rename netlink callback struct
Date: Wed, 21 Jun 2017 09:04:57 -0500
Message-ID: <022001d2ea97$5d5860c0$18092240$@opengridcomputing.com>
References: <20170621060528.3752-1-leon@kernel.org> <20170621060528.3752-7-leon@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <linux-rdma@vger.kernel.org>,
        "'Chien Tin Tung'" <chien.tin.tung@intel.com>,
        "'Stephen Hemminger'" <stephen@networkplumber.org>,
        "'Jiri Pirko'" <jiri@mellanox.com>,
        "'Ariel Almog'" <ariela@mellanox.com>,
        "'Linux Netdev'" <netdev@vger.kernel.org>,
        "'Leon Romanovsky'" <leonro@mellanox.com>
To: "'Leon Romanovsky'" <leon@kernel.org>,
        "'Doug Ledford'" <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:52527 "EHLO
        smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750999AbdFUOEy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 10:04:54 -0400
In-Reply-To: <20170621060528.3752-7-leon@kernel.org>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Leon Romanovsky <leonro@mellanox.com>
> 
> The RDMA netlink client infrastructure was removed and made
> obsolete the old name (ibnl_client_cbs). This patch renames
> to the more appropriate name (rdma_nl_cbs).
> 
> Signed-off-by: Leon Romanovsky <leonro@mellanox.com>

Looks good.

Reviewed-by: Steve Wise <swise@opengridcomputing.com>
