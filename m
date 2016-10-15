From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/2] rds: logging neatening
Date: Sat, 15 Oct 2016 11:53:20 -0700
Message-ID: <cover.1476557523.git.joe@perches.com>
Cc: Santosh Shilimkar <santosh.shilimkar@oracle.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches (2):
  rds: Remove unused rds_conn_error
  rds: Remove duplicate prefix from rds_conn_path_error use

 net/rds/connection.c | 15 ---------------
 net/rds/rds.h        |  4 ----
 net/rds/threads.c    |  3 +--
 3 files changed, 1 insertion(+), 21 deletions(-)

-- 
2.10.0.rc2.1.g053435c
