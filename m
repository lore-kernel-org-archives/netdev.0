From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] smc91x: SMC_IO_SHIFT platform data support for default
	case
Date: Mon, 8 Sep 2008 21:19:27 +1000
Message-ID: <20080908111922.GA15553@verge.net.au>
References: <20080908050234.11554.10123.sendpatchset@rx1.opensource.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.miao@marvell.com,
	luca.santini@spesonline.com, nico@cam.org, linux-sh@vger.kernel.org
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:38589 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752392AbYIHLTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 07:19:33 -0400
Content-Disposition: inline
In-Reply-To: <20080908050234.11554.10123.sendpatchset@rx1.opensource.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 08, 2008 at 02:02:34PM +0900, Magnus Damm wrote:
> From: Magnus Damm <damm@igel.co.jp>
> 
> Commit 159198862adad7109bb347bb30a620f67beac45f added SMC_IO_SHIFT
> platform data support. After that ARM board support was added.
> 
> The default case is still missing though, so on SuperH SMC_IO_SHIFT
> is constantly zero regardless of what you pass as platform data.

Hi Magnus,

I beleive that its now common practice to include the subject
of a commit along with its id, as the latter can change as
it moves from tree to tree.

