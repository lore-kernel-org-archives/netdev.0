From: "Ben Hutchings (bhutchings)" <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2] mii: Remove references to DP83840 PHY in mii.h
Date: Thu, 01 Sep 2011 19:15:42 +0100
Message-ID: <1314900942.2733.14.camel@bwh-desktop>
References: <1314804928-7353-1-git-send-email-mark.einon@gmail.com>
	 <1314868937-2536-1-git-send-email-mark.einon@gmail.com>
	 <1314868937-2536-2-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Mark Einon <mark.einon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 16.186.34.193.bridgep.com ([193.34.186.16]:60568 "EHLO
	localhost.localdomain" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754084Ab2ADSfe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 13:35:34 -0500
In-Reply-To: <1314868937-2536-2-git-send-email-mark.einon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-09-01 at 10:22 +0100, Mark Einon wrote:
> There are references to this PHY chip in the generic mii.h header, so removing them.
> Re-jiggle the changed comments, in response to points raised by Ben Hutchings.
> 
> Signed-off-by: Mark Einon <mark.einon@gmail.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Ben.
