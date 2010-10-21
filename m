From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] vmxnet3: remove set_flag_le{16,64} helpers
Date: Thu, 21 Oct 2010 03:57:41 -0700 (PDT)
Message-ID: <20101021.035741.68130271.davem@davemloft.net>
References: <1287642721-5997-1-git-send-email-harvey.harrison@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbhatewara@vmware.com, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43035
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754262Ab0JUK5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 06:57:18 -0400
In-Reply-To: <1287642721-5997-1-git-send-email-harvey.harrison@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Wed, 20 Oct 2010 23:32:01 -0700

> It's easier to just annotate the constants as little endian types and set/clear
> the flags directly.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---i
> Sorry, missed a git add and left a line out of the previous patch.

Could you please rebase this against net-next-2.6 since I've
applied Stephen Hemminger's patch.

Thanks!
