From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] rds: prevent dereference of a NULL device in
 rds_iw_laddr_check
Date: Mon, 31 Mar 2014 16:26:07 -0400 (EDT)
Message-ID: <20140331.162607.153228065356865845.davem@davemloft.net>
References: <1396139975-5314-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chien.yen@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sasha.levin@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1396139975-5314-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <sasha.levin@oracle.com>
Date: Sat, 29 Mar 2014 20:39:35 -0400

> Binding might result in a NULL device which is later dereferenced
> without checking.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Applied, thanks Sasha.
