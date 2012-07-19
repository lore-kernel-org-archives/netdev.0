From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH net-next] asix: AX88172A driver depends on phylib
Date: Fri, 20 Jul 2012 01:01:26 +0800
Message-ID: <20120719170126.GA19361@localhost>
References: <1342699339-13871-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Christian Riesch <christian.riesch@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:39999 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751189Ab2GSRBu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2012 13:01:50 -0400
Content-Disposition: inline
In-Reply-To: <1342699339-13871-1-git-send-email-christian.riesch@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 19, 2012 at 02:02:19PM +0200, Christian Riesch wrote:
> Since commit 16626b0cc3d5afe250850f96759b241f8a403b52 the asix
> driver depends on the phylib. Select phylib when the asix driver is
> selected.

Tested-by: Fengguang Wu <fengguang.wu@intel.com>
