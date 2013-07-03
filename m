From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH V2 2/3] usbnet: cdc_ncm: export cdc_ncm_tx_fixup and cdc_ncm_rx_fixup
Date: Wed, 03 Jul 2013 17:19:13 +0400
Message-ID: <51D424D1.2010507@cogentembedded.com>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso> <87wqp9xja5.fsf@nemi.mork.no> <alpine.LNX.2.02.1307021855270.19053@eeeadesso> <alpine.LNX.2.02.1307022202570.26010@eeeadesso> <alpine.LNX.2.02.1307022207060.26010@eeeadesso> <alpine.LNX.2.02.1307022210470.26010@eeeadesso> <alpine.LNX.2.02.1307022213380.26010@eeeadesso> <alpine.LNX.2.02.1307030836270.12831@eeeadesso> <alpine.LNX.2.02.1307030908090.13789@eeeadesso> <871u7gvz2z.fsf@nemi.mork.no> <alpine.LNX.2.02.1307031455460.24525@eeeadesso>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	netdev@vger.kernel.org
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:38410 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753819Ab3GCNTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 09:19:16 -0400
Received: by mail-lb0-f176.google.com with SMTP id z5so204831lbh.21
        for <netdev@vger.kernel.org>; Wed, 03 Jul 2013 06:19:15 -0700 (PDT)
In-Reply-To: <alpine.LNX.2.02.1307031455460.24525@eeeadesso>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03-07-2013 17:00, Enrico Mioso wrote:

> Export cdc_ncm_{tx,rx}_fixup functions, which may be re-used in drivers that
> implement ncm-like protocols.

> Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>
> v2: removed spurious blank lines

    Patches #1 and #2 should actually be merged.

WBR, Sergei
