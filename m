From: Alexander Stein <alexander.stein@systec-electronic.com>
Subject: Re: [PATCH 0/3] net: macb: Fix coding style issues
Date: Tue, 08 Mar 2016 08:06:43 +0100
Message-ID: <1562860.N8xpQysp6D@ws-stein>
References: <1457367460-9123-1-git-send-email-moritz.fischer@ettus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Moritz Fischer <moritz.fischer@ettus.com>, nicolas.ferre@atmel.com,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from webbox1416.server-home.net ([77.236.96.61]:58091 "EHLO
	webbox1416.server-home.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753957AbcCHHGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 02:06:52 -0500
In-Reply-To: <1457367460-9123-1-git-send-email-moritz.fischer@ettus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Monday 07 March 2016 08:17:36, Moritz Fischer wrote:
> this series deals with most of the checkpatch warnings
> generated for macb. There are two BUG_ON()'s that I didn't touch, yet,
> that were suggested by checkpatch, that I can address in a follow up
> commit if needed.

I think addressing those BUG_ON() warnings would be nice as they can affect a running system pretty bad.

Best regards,
Alexander
