From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] switchdev: add netlink flags to IPv4 FIB add
 op
Date: Mon, 09 Mar 2015 23:57:06 -0400 (EDT)
Message-ID: <20150309.235706.726828507538393841.davem@davemloft.net>
References: <1425934749-18567-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, jhs@mojatatu.com,
	roopa@cumulusnetworks.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45118 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917AbbCJD5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 23:57:08 -0400
In-Reply-To: <1425934749-18567-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Mon,  9 Mar 2015 13:59:09 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> Pass in the netlink flags (NLM_F_*) into switchdev driver for IPv4 FIB add op
> to allow driver to 1) optimize hardware updates, 2) handle ip route prepend
> and append commands correctly.
> 
> Suggested-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Suggested-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Applied, thanks Scott.
