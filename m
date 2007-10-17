From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] e1000e: fix error checks
Date: Tue, 16 Oct 2007 21:15:48 -0400
Message-ID: <47156244.1030201@garzik.org>
References: <20071015210213.26666.90484.stgit@localhost.localdomain> <20071015210221.26666.14629.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.ok, netdev@vger.kernel.org, bunk@kernel.org,
	joe@perches.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47520 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965916AbXJQBPv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 21:15:51 -0400
In-Reply-To: <20071015210221.26666.14629.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> From: Adrian Bunk <bunk@kernel.org>
> 
> Spotted by the Coverity checker.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

applied all three patches (1-2, and then the singleton)


