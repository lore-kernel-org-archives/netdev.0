From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.22] cxgb3 - fix register to stop bc/mc traffic
Date: Wed, 27 Jun 2007 02:33:29 -0400
Message-ID: <468204B9.5000400@garzik.org>
References: <20070625221930.19394.90772.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37840 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756879AbXF0Gdc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2007 02:33:32 -0400
In-Reply-To: <20070625221930.19394.90772.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Divy Le Ray wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Use the right register to stop broadcast/multicast traffic. 
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

applied to #upstream-fixes


