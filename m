From: Hin-Tak Leung <htl10@users.sourceforge.net>
Subject: Re: [PATCH 085/493] net/wireless: remove use of __devexit_p
Date: Thu, 22 Nov 2012 06:04:39 +0000 (GMT)
Message-ID: <1353564279.48819.YahooMailClassic@web172305.mail.ir2.yahoo.com>
References: <1353349642-3677-85-git-send-email-wfp5p@virginia.edu>
Reply-To: htl10@users.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org, Bill Pemberton <wfp5p@virginia.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm5.bullet.mail.ird.yahoo.com ([77.238.189.62]:47299 "EHLO
	nm5.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757651Ab2KVVQf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2012 16:16:35 -0500
In-Reply-To: <1353349642-3677-85-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--- On Mon, 19/11/12, Bill Pemberton <wfp5p@virginia.edu> wrote:

> CONFIG_HOTPLUG is going away as an
> option so __devexit_p is no longer
> needed.
> 
> Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
> Cc: "John W. Linville" <linville@tuxdriver.com>
> 
> Cc: Jiri Slaby <jirislaby@gmail.com>
> 
> Cc: Nick Kossifidis <mickflemm@gmail.com>
> 
> Cc: "Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>
> 
> Cc: Simon Kelley <simon@thekelleys.org.uk>
> 
> Cc: Stefano Brivio <stefano.brivio@polimi.it>
> 
> Cc: Stanislav Yakovlev <stas.yakovlev@gmail.com>
> 
> Cc: Dan Williams <dcbw@redhat.com>
> 
> Cc: Christian Lamparter <chunkeey@googlemail.com>
> 
> Cc: Ivo van Doorn <IvDoorn@gmail.com>
> 
> Cc: Gertjan van Wingerde <gwingerde@gmail.com>
> 
> Cc: Helmut Schaa <helmut.schaa@googlemail.com>
> 
> Cc: Herton Ronaldo Krzesinski <herton@canonical.com>
> 
> Cc: Hin-Tak Leung <htl10@users.sourceforge.net>
> 
> Cc: Larry Finger <Larry.Finger@lwfinger.net>
> 
> Cc: Luciano Coelho <coelho@ti.com> 
> Cc: linux-wireless@vger.kernel.org
> 
> Cc: netdev@vger.kernel.org
> 
> Cc: ath5k-devel@lists.ath5k.org
> 
> Cc: b43-dev@lists.infradead.org
> 
> Cc: brcm80211-dev-list@broadcom.com
> 
> Cc: libertas-dev@lists.infradead.org
> 
> Cc: users@rt2x00.serialmonkey.com
> 
> ---

Acked-by: Hin-Tak Leung <htl10@users.sourceforge.net>

The rtl818x parts.
