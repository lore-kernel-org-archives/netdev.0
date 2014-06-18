From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 0/3] XLR/XLS network driver update and fixes
Date: Wed, 18 Jun 2014 18:03:10 +0200
Message-ID: <20140618160309.GG26335@linux-mips.org>
References: <cover.1403096668.git.ganesanr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kristina.martsenko@gmail.com, gregkh@linuxfoundation.org,
	jchandra@broadcom.com, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
To: ganesanr@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:43526 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbaFRQDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 12:03:20 -0400
Received: from localhost.localdomain ([127.0.0.1]:34135 "EHLO linux-mips.org"
        rhost-flags-OK-OK-OK-FAIL) by eddie.linux-mips.org with ESMTP
        id S6859954AbaFRQDR4PIto (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jun 2014 18:03:17 +0200
Content-Disposition: inline
In-Reply-To: <cover.1403096668.git.ganesanr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 18, 2014 at 06:43:55PM +0530, ganesanr@broadcom.com wrote:

> From: Ganesan Ramalingam <ganesanr@broadcom.com>
> 
> Patches has following changes:
> 
>  * Fixed compilation failure caused by change in COP2 API
>  * SGMII PHY address calculation was wrong, fixed
>  * Updated the driver to have single parent device for a XLR/XLS
>    network block with multiple network devices under it
>  * Fixed comment format

Patches 1 and 2 apply cleanly but I'm getting a reject for patch 3.

  Ralf
