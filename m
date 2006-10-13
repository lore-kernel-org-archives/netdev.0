From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/02 V3] net/ipv6: seperate sit driver to extra module
Date: Fri, 13 Oct 2006 15:06:08 -0700 (PDT)
Message-ID: <20061013.150608.63128976.davem@davemloft.net>
References: <20061010153745.GA27455@zlug.org>
	<452FD6F6.3090907@l4x.org>
	<20061013191744.GA30089@zlug.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdi@l4x.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:36070
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751218AbWJMWGH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 18:06:07 -0400
To: joro-lkml@zlug.org
In-Reply-To: <20061013191744.GA30089@zlug.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joerg Roedel <joro-lkml@zlug.org>
Date: Fri, 13 Oct 2006 21:17:45 +0200

> On Fri, Oct 13, 2006 at 08:12:06PM +0200, Jan Dittmer wrote:
> > This is missing the MODULE_LICENSE statements and taints the kernel upon
> > loading. License is obvious from the beginning of the file.
 ...
> > Signed-off-by: Jan Dittmer <jdi@l4x.org>
> Signed-off-by: Joerg Roedel <joro-lkml@zlug.org>

Applied, thanks for catching this Jan.
