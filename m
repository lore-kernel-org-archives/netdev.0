From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.21 1/4] cxgb3 - fix ethtool cmd on multiple queues
 port
Date: Fri, 23 Mar 2007 01:50:02 -0400
Message-ID: <46036A8A.2050606@garzik.org>
References: <20070318201001.16269.86377.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60447 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753188AbXCWFuE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 01:50:04 -0400
In-Reply-To: <20070318201001.16269.86377.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

divy@chelsio.com wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Limit ethtool -g/-G to the given port's queues.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

applied 1-4


