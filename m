From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 01/39] mv643xx_eth: reverse topological sort of
	functions
Date: Thu, 5 Jun 2008 04:23:48 -0700
Message-ID: <20080605112348.GD1059@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-2-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:39251 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754759AbYFELXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 07:23:55 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-2-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:16PM +0200, Lennert Buytenhek wrote:
> This patch performs a reverse topological sort of all functions in
> mv643xx_eth.c, so that we can get rid of all forward declarations,
> and end up with a more understandable driver due to related functions
> being grouped together.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c | 3438 ++++++++++++++++++++++-----------------------

Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
