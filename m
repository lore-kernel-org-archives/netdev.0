From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: [PATCH V2 2/3] usbnet: cdc_ncm: export cdc_ncm_tx_fixup and
 cdc_ncm_rx_fixup
Date: Wed, 3 Jul 2013 15:22:34 +0200 (CEST)
Message-ID: <alpine.LNX.2.02.1307031521370.25440@eeeadesso>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso> <87wqp9xja5.fsf@nemi.mork.no> <alpine.LNX.2.02.1307021855270.19053@eeeadesso> <alpine.LNX.2.02.1307022202570.26010@eeeadesso> <alpine.LNX.2.02.1307022207060.26010@eeeadesso>
 <alpine.LNX.2.02.1307022210470.26010@eeeadesso> <alpine.LNX.2.02.1307022213380.26010@eeeadesso> <alpine.LNX.2.02.1307030836270.12831@eeeadesso> <alpine.LNX.2.02.1307030908090.13789@eeeadesso> <871u7gvz2z.fsf@nemi.mork.no> <alpine.LNX.2.02.1307031455460.24525@eeeadesso>
 <51D424D1.2010507@cogentembedded.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Enrico Mioso <mrkiko.rs@gmail.com>,
	=?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:44895 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837Ab3GCNWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 09:22:14 -0400
Received: by mail-we0-f173.google.com with SMTP id x54so116117wes.4
        for <netdev@vger.kernel.org>; Wed, 03 Jul 2013 06:22:12 -0700 (PDT)
In-Reply-To: <51D424D1.2010507@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you very much Serghi! Applying..


On Wed, 3 Jul 2013, Sergei Shtylyov wrote:

==Date: Wed, 03 Jul 2013 17:19:13 +0400
==From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
==To: Enrico Mioso <mrkiko.rs@gmail.com>
==Cc: Bj?rn Mork <bjorn@mork.no>, netdev@vger.kernel.org
==Subject: Re: [PATCH V2 2/3] usbnet: cdc_ncm: export cdc_ncm_tx_fixup and
==    cdc_ncm_rx_fixup
==
==Hello.
==
==On 03-07-2013 17:00, Enrico Mioso wrote:
==
==> Export cdc_ncm_{tx,rx}_fixup functions, which may be re-used in drivers that
==> implement ncm-like protocols.
==
==> Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>
==> v2: removed spurious blank lines
==
==   Patches #1 and #2 should actually be merged.
==
==WBR, Sergei
==
==
