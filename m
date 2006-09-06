From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] myri10ge: update the firmware download URL in Kconfig
Date: Wed, 06 Sep 2006 11:05:38 -0400
Message-ID: <44FEE3C2.30707@garzik.org>
References: <44FE2B5A.7020506@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:12762 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751317AbWIFPFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 11:05:41 -0400
To: Brice Goglin <brice@myri.com>
In-Reply-To: <44FE2B5A.7020506@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin wrote:
> Jeff,
> 
> Could you please push the following patch to Linus before 2.6.18?
> It updates the firmware download URL in Kconfig to match the header
> in drivers/net/myri10ge/myri10ge.c.
> 
> Thanks!
> Brice Goglin

In future patches, please ensure comments such as the above quoted 
always follow the "---" terminator line.  Otherwise, I must hand-edit 
out these comments, before running git-applymbox to apply your patch(es).

applied


