From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH] Fix MAC address length check
Date: Mon, 27 Jun 2016 11:02:11 -0700
Message-ID: <20160627110211.004f5705@xeon-e3>
References: <1466589938-14448-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:42524 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751638AbcF0SCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 14:02:02 -0400
In-Reply-To: <1466589938-14448-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Jun 2016 12:05:38 +0200
Phil Sutter <phil@nwl.cc> wrote:

> I forgot to change the variable in the conditional, too.
> 
> Fixes: 8fe58d58941f4 ("iplink: Check address length via netlink")
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applied
