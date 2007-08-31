From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 9/11] cxgb3 - engine microcode update
Date: Fri, 31 Aug 2007 09:38:22 -0400
Message-ID: <46D819CE.5050207@garzik.org>
References: <20070822034947.9404.87301.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58575 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965118AbXHaNiX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 09:38:23 -0400
In-Reply-To: <20070822034947.9404.87301.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Divy Le Ray wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Load microcode engine when the interface
> is configured up.
> Bump up version to 1.1.0.
> Allow the driver to be and running with
> older microcode images.
> Allow ethtool to log the microcode version.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

ACK patches 9-14, but dropped, since they do not apply to #upstream 
(probably due to fixes sent into 2.6.23-rc)


