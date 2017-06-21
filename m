From: "Steve Wise" <swise@opengridcomputing.com>
Subject: RE: [PATCH rdma-next 02/19] RDMA/netlink: Simplify the put_msg and put_attr
Date: Wed, 21 Jun 2017 09:01:29 -0500
Message-ID: <021801d2ea96$e1810a10$a4831e30$@opengridcomputing.com>
References: <20170621060528.3752-1-leon@kernel.org> <20170621060528.3752-3-leon@kernel.org>
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
Received: from smtp.opengridcomputing.com ([72.48.136.20]:52479 "EHLO
        smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751041AbdFUOB0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 10:01:26 -0400
In-Reply-To: <20170621060528.3752-3-leon@kernel.org>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Leon Romanovsky <leonro@mellanox.com>
> 
> Reuse standard macros to cancel the netlink message
> in case of error.
> 
> Signed-off-by: Leon Romanovsky <leonro@mellanox.com>

Looks good.

Reviewed-by: Steve Wise <swise@opengridcomputing.com>
