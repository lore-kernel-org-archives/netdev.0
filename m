From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: rtl8168e-vl dropping tftp ack
Date: Fri, 26 Apr 2013 01:03:59 +0200
Message-ID: <20130425230359.GA27526@electric-eye.fr.zoreil.com>
References: <516EB23B.3080504@canonical.com>
 <20130417213251.GA13790@electric-eye.fr.zoreil.com>
 <516FC218.3060002@canonical.com>
 <20130418215501.GB8944@electric-eye.fr.zoreil.com>
 <DFF62ECF5DF14C65A71A35581D58FFA9@realtek.com.tw>
 <20130419061425.GA14843@electric-eye.fr.zoreil.com>
 <55FF74168B2A4152AD875C000535466F@realtek.com.tw>
 <51790BDE.7090500@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hayeswang <hayeswang@realtek.com>, netdev@vger.kernel.org,
	"'nic_swsd'" <nic_swsd@realtek.com>
To: Stefan Bader <stefan.bader@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:45187 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757622Ab3DYXEI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 19:04:08 -0400
Content-Disposition: inline
In-Reply-To: <51790BDE.7090500@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefan Bader <stefan.bader@canonical.com> :
[...]
> This variant also seems to work (and does not drop the tftp packet). Whichever
> path looks more suitable to you, you could add my tested-by to both.

It's a bit late today. I'll submit it tomorrow.

> We should also flag whichever change results from this as stable material as I
> could see this happen even in v3.2 (just did not try further back).

Davem usually takes care of the last stable. I'll forward it to every
8168evl-supporting stable kernel once it gets included in mainline.

Thanks.

-- 
Ueimor
