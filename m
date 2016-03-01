From: David Miller <davem@davemloft.net>
Subject: Re: [net-next][PATCH v2 00/13] RDS: Major clean-up with couple of
 new features for 4.6
Date: Tue, 01 Mar 2016 17:33:08 -0500 (EST)
Message-ID: <20160301.173308.391621325255066441.davem@davemloft.net>
References: <1456625990-4739-1-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: santosh.shilimkar@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456625990-4739-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


When I try to apply this series, it (strangely) fails on the first patch with:

Applying: RDS: Drop stale iWARP RDMA transport
error: removal patch leaves file contents
error: net/rds/iw.c: patch does not apply
error: removal patch leaves file contents
error: net/rds/iw.h: patch does not apply
error: removal patch leaves file contents
error: net/rds/iw_cm.c: patch does not apply
error: removal patch leaves file contents
error: net/rds/iw_rdma.c: patch does not apply
error: removal patch leaves file contents
error: net/rds/iw_recv.c: patch does not apply
error: removal patch leaves file contents
error: net/rds/iw_ring.c: patch does not apply
error: removal patch leaves file contents
error: net/rds/iw_send.c: patch does not apply
error: removal patch leaves file contents
error: net/rds/iw_stats.c: patch does not apply
error: removal patch leaves file contents
error: net/rds/iw_sysctl.c: patch does not apply

Please sort this out and respin, thanks.
