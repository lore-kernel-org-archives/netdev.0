From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCH 8/8] macb: support data bus widths > 32 bits
Date: Fri, 11 Mar 2011 13:55:23 +0100
Message-ID: <20110311125523.GN9351@game.jcrosoft.org>
References: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
 <1299751843-9743-9-git-send-email-jamie@jamieiles.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	nicolas.ferre@atmel.com
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 64.mail-out.ovh.net ([91.121.185.65]:46633 "HELO
	64.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753878Ab1CKNAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2011 08:00:53 -0500
Content-Disposition: inline
In-Reply-To: <1299751843-9743-9-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10:10 Thu 10 Mar     , Jamie Iles wrote:
> Some GEM implementations may support data bus widths up to 128 bits.
> Allow the platform data to specify the data bus width and let the driver
> program it up.
> 
can we detect it?

Best Regards,
J.
