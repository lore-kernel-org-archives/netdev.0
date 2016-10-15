From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [rds-devel] [PATCH 1/2] rds: Remove unused rds_conn_error
Date: Sat, 15 Oct 2016 15:00:48 -0400
Message-ID: <20161015190048.GI31471@oracle.com>
References: <cover.1476557523.git.joe@perches.com>
 <01fddf3af8f7757d0e79e4f25d7eb8b246e3d695.1476557523.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Santosh Shilimkar <santosh.shilimkar@oracle.com>,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        rds-devel@oss.oracle.com, "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26738 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752654AbcJOTBc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2016 15:01:32 -0400
Content-Disposition: inline
In-Reply-To: <01fddf3af8f7757d0e79e4f25d7eb8b246e3d695.1476557523.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (10/15/16 11:53), Joe Perches wrote:
> This macro's last use was removed in commit d769ef81d5b59
> ("RDS: Update rds_conn_shutdown to work with rds_conn_path")
> so make the macro and the __rds_conn_error function definition
> and declaration disappear.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
