From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] rds: Remove unused rds_conn_error
Date: Mon, 17 Oct 2016 11:07:33 -0400 (EDT)
Message-ID: <20161017.110733.866131367668424465.davem@davemloft.net>
References: <cover.1476557523.git.joe@perches.com>
        <01fddf3af8f7757d0e79e4f25d7eb8b246e3d695.1476557523.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: santosh.shilimkar@oracle.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <01fddf3af8f7757d0e79e4f25d7eb8b246e3d695.1476557523.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sat, 15 Oct 2016 11:53:21 -0700

> This macro's last use was removed in commit d769ef81d5b59
> ("RDS: Update rds_conn_shutdown to work with rds_conn_path")
> so make the macro and the __rds_conn_error function definition
> and declaration disappear.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
