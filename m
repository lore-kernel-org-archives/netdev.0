From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rds: make local functions/variables static
Date: Thu, 21 Oct 2010 04:31:56 -0700 (PDT)
Message-ID: <20101021.043156.71573474.davem@davemloft.net>
References: <20101019110833.7ef05180@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy.grover@oracle.com, zach.brown@oracle.com,
	chris.mason@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37626
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757623Ab0JULbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 07:31:33 -0400
In-Reply-To: <20101019110833.7ef05180@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 19 Oct 2010 11:08:33 -0700

> The RDS protocol has lots of functions that should be
> declared static. rds_message_get/add_version_extension is
> removed since it defined but never used.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
