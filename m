From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/13] bnx2x: Use VPD-R V0 entry to display firmware
 revision
Date: Sun, 18 Apr 2010 16:08:28 +0100
Message-ID: <1271603308.3679.208.camel@localhost>
References: <1271602093.27235.179.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com,
	dmitry@broadcom.com, Matt Carlson <mcarlson@broadcom.com>
To: Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:28520 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755025Ab0DRPId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Apr 2010 11:08:33 -0400
In-Reply-To: <1271602093.27235.179.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-04-18 at 17:48 +0300, Vladislav Zolotarov wrote:
> Use VPD-R V0 entry to display firmware revision
[...]

Matt Carlson already added VPD support functions and definitions to the
PCI core; you should use them.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

