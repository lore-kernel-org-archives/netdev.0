From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] forcedeth: mac address mcp77/79
Date: Wed, 30 Jan 2008 03:48:33 -0500
Message-ID: <47A039E1.6010901@pobox.com>
References: <479DF3B8.2000204@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>,
	stable@kernel.org
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33461 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754987AbYA3Ish (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 03:48:37 -0500
In-Reply-To: <479DF3B8.2000204@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ayaz Abdulla wrote:
> This patch is a critical fix for MCP77 and MCP79 devices. The feature 
> flags were missing the define for correct mac address 
> (DEV_HAS_CORRECT_MACADDR).
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

applied (upstream)


