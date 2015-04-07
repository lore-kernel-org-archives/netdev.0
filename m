From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [net-next] wireless: Use bool function returns of true/false
 insteadof 1/0
Date: Tue,  7 Apr 2015 17:11:21 +0000 (UTC)
Message-ID: <20150407171121.2DA00140D3F@smtp.codeaurora.org>
References: <1427678982.2715.55.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stefano Brivio <stefano.brivio@polimi.it>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	brcm80211-dev-list <brcm80211-dev-list@broadcom.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:33104 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752721AbbDGRLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 13:11:22 -0400
In-Reply-To: <1427678982.2715.55.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Use bool constants as the return values instead of 1 and 0.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
