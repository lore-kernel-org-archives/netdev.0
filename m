From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: [PATCH 085/493] net/wireless: remove use of __devexit_p
Date: Mon, 19 Nov 2012 21:56:14 +0100
Message-ID: <50AA9CEE.2030205@broadcom.com>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
 <1353349642-3677-85-git-send-email-wfp5p@virginia.edu>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jiri Slaby" <jirislaby@gmail.com>,
	"Nick Kossifidis" <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	"Simon Kelley" <simon@thekelleys.org.uk>,
	"Stefano Brivio" <stefano.brivio@polimi.it>,
	"Stanislav Yakovlev" <stas.yakovlev@gmail.com>,
	"Dan Williams" <dcbw@redhat.com>,
	"Christian Lamparter" <chunkeey@googlemail.com>,
	"Ivo van Doorn" <IvDoorn@gmail.com>,
	"Gertjan van Wingerde" <gwingerde@gmail.com>,
	"Helmut Schaa" <helmut.schaa@googlemail.com>,
	"Herton Ronaldo Krzesinski" <herton@canonical.com>,
	"Hin-Tak Leung" <htl10@users.sourceforge.net>,
	"Larry Finger" <Larry.Finger@lwfinger.net>,
	"Luciano Coelho" <coelho@ti.com>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, ath5k-devel@lists.ath5k.org,
	b43-dev@lists.infradead.org, brcm80211-dev-list@broadcom.com,
	libertas-
To: "Bill Pemberton" <wfp5p@virginia.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3239 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751791Ab2KSU4d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Nov 2012 15:56:33 -0500
In-Reply-To: <1353349642-3677-85-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/19/2012 07:20 PM, Bill Pemberton wrote:
> CONFIG_HOTPLUG is going away as an option so __devexit_p is no longer
> needed.

Acked-by: Arend van Spriel <arend@broadcom.com>
> Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
> Cc: brcm80211-dev-list@broadcom.com
 >
>   drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c | 2 +-

For this part of the patch obviously.

Gr. AvS
