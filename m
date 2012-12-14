From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bridge: remove temporary variable for MLDv2 maximum
 response code computation
Date: Fri, 14 Dec 2012 08:19:45 -0800
Message-ID: <20121214081945.26dbcb98@nehalam.linuxnetplumber.net>
References: <50CAEC97.2090609@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ang Way Chuang <wcang@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53481 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756581Ab2LNQWn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2012 11:22:43 -0500
In-Reply-To: <50CAEC97.2090609@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Dec 2012 17:08:39 +0800
Ang Way Chuang <wcang@sfc.wide.ad.jp> wrote:

> As suggested by Stephen Hemminger, this remove the temporary variable introduced in commit
> eca2a43bb0d2c6ebd528be6acb30a88435abe307
> 
> Signed-off-by: Ang Way Chuang <wcang@sfc.wide.ad.jp>

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
