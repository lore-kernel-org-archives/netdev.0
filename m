From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: tbench regression on each kernel release from 2.6.22 -> 2.6.28
Date: Tue, 19 Aug 2008 09:01:46 +0800
Message-ID: <1219107706.8781.6.camel@ymzhang>
References: <48A086B6.2000901@linux-foundation.org>
	 <20080811.141501.01468546.davem@davemloft.net>
	 <Pine.LNX.4.64.0808121058550.4551@wrl-59.cs.helsinki.fi>
	 <1219025114.25933.6.camel@ymzhang>  <48A98228.9090006@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:24561 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751475AbYHSBCv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Aug 2008 21:02:51 -0400
In-Reply-To: <48A98228.9090006@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2008-08-18 at 09:07 -0500, Christoph Lameter wrote:
> Zhang, Yanmin wrote:
> 
> > Other regressions on other machines are similar.
> 
> There are AIM7 regressions that are similar to tbench.
> 
> 2.6.22	28436
> 2.6.26	23064

Mostly, AIM7 has about 4~5% regression on my machines. As AIM7 result is stable,
so 4% is big. 

