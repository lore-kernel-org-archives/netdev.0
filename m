From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rds: prevent dereference of a NULL device
Date: Fri, 27 Dec 2013 12:34:27 -0500 (EST)
Message-ID: <20131227.123427.362811725046494702.davem@davemloft.net>
References: <1387428582-961-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: venkat.x.venkatsubra@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sasha.levin@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1387428582-961-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <sasha.levin@oracle.com>
Date: Wed, 18 Dec 2013 23:49:42 -0500

> Binding might result in a NULL device, which is dereferenced
> causing this BUG:
 ...
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Applied and queued up for -stable, thanks.
