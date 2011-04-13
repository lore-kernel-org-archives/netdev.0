From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] net: can: mscan: fix build breakage in mpc5xxx_can
Date: Wed, 13 Apr 2011 12:17:06 +0200
Message-ID: <4DA57822.30808@grandegger.com>
References: <1302688168-26862-1-git-send-email-agust@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@secretlab.ca>
To: Anatolij Gustschin <agust@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:40705 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757164Ab1DMKOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 06:14:50 -0400
In-Reply-To: <1302688168-26862-1-git-send-email-agust@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/13/2011 11:49 AM, Anatolij Gustschin wrote:
> Commit 74888760d40b3ac9054f9c5fa07b566c0676ba2d
> "dt/net: Eliminate users of of_platform_{,un}register_driver"
> broke building mscan driver. Fix it.
> 
> Signed-off-by: Anatolij Gustschin <agust@denx.de>
> Cc: Grant Likely <grant.likely@secretlab.ca>

Acked-by: Wolfgang Grandegger <wg@grandegger.com>
