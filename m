From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] rds: Remove duplicate prefix from
 rds_conn_path_error use
Date: Mon, 17 Oct 2016 11:07:39 -0400 (EDT)
Message-ID: <20161017.110739.894569165695479745.davem@davemloft.net>
References: <cover.1476557523.git.joe@perches.com>
        <832b0d2c1b31c10db7692f65f1ba77e779db15e1.1476557523.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: santosh.shilimkar@oracle.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56450 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934755AbcJQPHm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 11:07:42 -0400
In-Reply-To: <832b0d2c1b31c10db7692f65f1ba77e779db15e1.1476557523.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sat, 15 Oct 2016 11:53:22 -0700

> rds_conn_path_error already prefixes "RDS:" to the output.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
