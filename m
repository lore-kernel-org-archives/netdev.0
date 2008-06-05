From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 07/39] mv643xx_eth: delete unused port serial control
	register bit defines
Date: Thu, 5 Jun 2008 04:27:14 -0700
Message-ID: <20080605112714.GH1059@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-8-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:51431 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755166AbYFEL1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 07:27:18 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-8-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:22PM +0200, Lennert Buytenhek wrote:
> Over half of the port serial control register bit defines are never
> used, and the PORT_SERIAL_CONTROL_DEFAULT_VALUE define is never used
> either.  Keep only those defines that are actually used.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |   78 +++++++++------------------------------------
>  1 files changed, 15 insertions(+), 63 deletions(-)

Acked-by: Dale Farnsworth <dale@farnsworth.org>
