From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] PHY: Export phy ethtool helpers
Date: Tue, 23 Jan 2007 00:51:50 -0500
Message-ID: <45B5A276.7080202@pobox.com>
References: <Pine.LNX.4.64.0701201637290.17538@gate.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45397 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933011AbXAWFvy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 00:51:54 -0500
To: Kumar Gala <galak@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.64.0701201637290.17538@gate.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kumar Gala wrote:
> We need to export phy_ethtool_gset and phy_ethtool_sset to allow drivers 
> that
> use these functions to be built as modules.
> 
> Signed-off-by: Kumar Gala <galak@kernel.crashing.org>

your patch was corrupt.  applied manually

	Jeff



