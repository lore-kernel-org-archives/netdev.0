From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] iwlegacy: 4965-mac: constify il_sensitivity_ranges
 structure
Date: Mon, 4 Jan 2016 10:37:38 +0100
Message-ID: <20160104093737.GB2588@redhat.com>
References: <1451474449-17912-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39734 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752241AbcADJi5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 04:38:57 -0500
Content-Disposition: inline
In-Reply-To: <1451474449-17912-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 30, 2015 at 12:20:49PM +0100, Julia Lawall wrote:
> The il_sensitivity_ranges is never modified, so declare it as const.
> 
> Done with the help of Coccinelle.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Acked-by: Stanislaw Gruszka <sgruszka@redhat.com>
