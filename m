From: David Miller <davem@davemloft.net>
Subject: Re: [patch] rds: cleanup: remove unneeded variable
Date: Wed, 24 Mar 2010 13:37:04 -0700 (PDT)
Message-ID: <20100324.133704.247147708.davem@davemloft.net>
References: <20100324115730.GF21571@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy.grover@oracle.com, shemminger@vyatta.com, adobriyan@gmail.com,
	eparis@redhat.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42970
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932889Ab0CXUgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 16:36:41 -0400
In-Reply-To: <20100324115730.GF21571@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Wed, 24 Mar 2010 14:57:30 +0300

> We never use "sk" so this patch removes it.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied, thanks Dan.
