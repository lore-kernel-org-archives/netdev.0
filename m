From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/5] e1000e: limit EEPROM size accesses
Date: Sat, 12 Apr 2008 05:02:27 -0400
Message-ID: <48007AA3.2010405@garzik.org>
References: <20080402204802.29122.81707.stgit@localhost.localdomain> <20080402204807.29122.77075.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59401 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757051AbYDLJCa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 05:02:30 -0400
In-Reply-To: <20080402204807.29122.77075.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Auke Kok wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000e/82571.c  |    4 ++++
>  drivers/net/e1000e/es2lan.c |    4 ++++
>  2 files changed, 8 insertions(+), 0 deletions(-)

applied 2-5

leaving patch #1 out of this patch due to discussion :/


