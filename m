From: David Miller <davem@davemloft.net>
Subject: Re: [net][PATCH v2 1/2] RDS: fix endianness for dp_ack_seq
Date: Sat, 16 Apr 2016 19:01:37 -0400 (EDT)
Message-ID: <20160416.190137.742652664138329375.davem@davemloft.net>
References: <1460655807-26236-1-git-send-email-santosh.shilimkar@oracle.com>
	<1460655807-26236-2-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: santosh.shilimkar@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460655807-26236-2-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Date: Thu, 14 Apr 2016 10:43:26 -0700

> From: Qing Huang <qing.huang@oracle.com>
> 
> dp->dp_ack_seq is used in big endian format. We need to do the
> big endianness conversion when we assign a value in host format
> to it.
> 
> Signed-off-by: Qing Huang <qing.huang@oracle.com>
> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>

Applied.
