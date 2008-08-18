From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: tbench regression on each kernel release from 2.6.22 -> 2.6.28
Date: Mon, 18 Aug 2008 09:07:36 -0500
Message-ID: <48A98228.9090006@linux-foundation.org>
References: <48A086B6.2000901@linux-foundation.org>	 <20080811.141501.01468546.davem@davemloft.net>	 <Pine.LNX.4.64.0808121058550.4551@wrl-59.cs.helsinki.fi> <1219025114.25933.6.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50086 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752530AbYHROH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 10:07:58 -0400
In-Reply-To: <1219025114.25933.6.camel@ymzhang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zhang, Yanmin wrote:

> Other regressions on other machines are similar.

There are AIM7 regressions that are similar to tbench.

2.6.22	28436
2.6.26	23064
