From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [PATCH wireless-2.6-git] prism54: WPA/RSN support for fullmac cards
Date: Mon, 30 Oct 2006 15:17:53 -0500
Message-ID: <43e72e890610301217g28d169eeu448944e170153948@mail.gmail.com>
References: <200610031457.33215.chunkeey@web.de>
	 <20061017213229.GC32614@tuxdriver.com>
	 <200610291335.07729.chunkeey@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.228]:29472 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1030591AbWJ3URz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Oct 2006 15:17:55 -0500
Received: by wr-out-0506.google.com with SMTP id i7so347562wra
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2006 12:17:54 -0800 (PST)
To: "chunkeey@web.de" <chunkeey@web.de>
In-Reply-To: <200610291335.07729.chunkeey@web.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/29/06, chunkeey@web.de <chunkeey@web.de> wrote:
> This patch completes WPA/RSN with TKIP support for all fullmac prism54 cards.
> I removed all parts which are not relevant for wpa_supplicant (managed mode).

This is great effort and thanks for it! My only concern with the patch
is breaking compatiblity with 2.4 but then again I'm tired of having
to keep this compat work up too and soon, after d80211 full force push
it may not be possible. So I ACK it.

  Luis
