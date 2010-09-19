From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] rds: double unlock in rds_ib_cm_handle_connect()
Date: Sun, 19 Sep 2010 11:59:58 -0700 (PDT)
Message-ID: <20100919.115958.246545861.davem@davemloft.net>
References: <20100918234259.GD6236@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy.grover@oracle.com, zach.brown@oracle.com, julia@diku.dk,
	tj@kernel.org, rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37824
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755274Ab0ISS7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Sep 2010 14:59:39 -0400
In-Reply-To: <20100918234259.GD6236@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Sun, 19 Sep 2010 01:42:59 +0200

> We unlock after we goto out.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
