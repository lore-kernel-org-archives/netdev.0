From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c:
 remove unnecessary null test before debugfs_remove_recursive
Date: Wed, 02 Jul 2014 17:05:54 -0700 (PDT)
Message-ID: <20140702.170554.1567814087607685055.davem@davemloft.net>
References: <1403902312-10930-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, hariprasad@chelsio.com,
	netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403902312-10930-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Fri, 27 Jun 2014 22:51:52 +0200

> Fix checkpatch warning:
> "WARNING: debugfs_remove_recursive(NULL) is safe this check is probably not required"
> 
> Cc: Hariprasad S <hariprasad@chelsio.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied to net-next.
