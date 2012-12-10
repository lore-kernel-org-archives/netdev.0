From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: ipgre rss is broken since gro
Date: Mon, 10 Dec 2012 07:17:17 -0800
Message-ID: <1355152637.27891.3.camel@edumazet-glaptop>
References: <504C9EFCA2D0054393414C9CB605C37F1BFB80B2@SJEXCHMB06.corp.ad.broadcom.com>
	 <504C9EFCA2D0054393414C9CB605C37F1BFB80D8@SJEXCHMB06.corp.ad.broadcom.com>
	 <CANn89iKE2RxRBWRuXGwjydQKjPLhPbcoZaJS5rcBKbJWWnL4ZQ@mail.gmail.com>
	 <1355018645.3113.0.camel@lb-tlvb-dmitry.il.broadcom.com>
	 <1355086161.3113.9.camel@lb-tlvb-dmitry.il.broadcom.com>
	 <CANn89iKtWuN=CRn-JBzmmo8jCCJQhZjAT8jA+9dgfmup99O03g@mail.gmail.com>
	 <504C9EFCA2D0054393414C9CB605C37F1BFC104B@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:64314 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752036Ab2LJPRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 10:17:20 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so2102552pad.19
        for <netdev@vger.kernel.org>; Mon, 10 Dec 2012 07:17:20 -0800 (PST)
In-Reply-To: <504C9EFCA2D0054393414C9CB605C37F1BFC104B@SJEXCHMB06.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-12-10 at 11:32 +0000, Dmitry Kravkov wrote:

> Current bnx2x do not apply RSS for GRE, non GRE RSS is working w/o problem.

What about you post the changes you did ?
