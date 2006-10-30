From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH wireless-2.6-git] prism54: WPA/RSN support for fullmac
	cards
Date: Mon, 30 Oct 2006 15:33:31 -0500
Message-ID: <1162240411.11682.2.camel@localhost.localdomain>
References: <200610031457.33215.chunkeey@web.de>
	 <20061017213229.GC32614@tuxdriver.com> <200610291335.07729.chunkeey@web.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37083 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751973AbWJ3UcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2006 15:32:11 -0500
To: chunkeey@web.de
In-Reply-To: <200610291335.07729.chunkeey@web.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-10-29 at 14:35 +0200, chunkeey@web.de wrote:
> This patch completes WPA/RSN with TKIP support for all fullmac prism54 cards.
> I removed all parts which are not relevant for wpa_supplicant (managed mode).
> 
> you can connect to your WLAN with: 
> wpa_supplicant -Dwext -c{WPA_CONF} -i{WPA_ETH} 
> 
> Signed-off-by: Christian Lamparter <chunkeey@web.de>
> 
> off-topic:
> Can someone please check my changelog for spelling "errors"?

What git tree or kernel source version is this patch based off?  It
doesn't appear to be based off 2.6.18, 2.6.19-rc3, or wireless-dev.  I
wanted to test it out with a WPA access point and see if there are
regressions...

Thanks,
Dan


