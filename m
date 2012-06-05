From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 5/5] gianfar_ethtool: coding style and
 whitespace cleanups
Date: Tue, 05 Jun 2012 13:10:11 +0200
Message-ID: <1338894611.2760.2327.camel@edumazet-glaptop>
References: <4FCD084D.6020408@computer.org>
	 <20120605.051437.1378262604943296071.davem@davemloft.net>
	 <4FCDE447.3030103@computer.org>  <4550590.BhQA539plh@flexo>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jan Ceuleers <jan.ceuleers@computer.org>,
	David Miller <davem@davemloft.net>, b06378@freescale.com,
	joe@perches.com, netdev@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:62312 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761835Ab2FELKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 07:10:16 -0400
Received: by bkcji2 with SMTP id ji2so4472930bkc.19
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2012 04:10:15 -0700 (PDT)
In-Reply-To: <4550590.BhQA539plh@flexo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-05 at 12:54 +0200, Florian Fainelli wrote:
> Hi,
> 
> On Tuesday 05 June 2012 12:49:43 Jan Ceuleers wrote:

> > The error I quoted was a fatal error, meaning that compilation did not
> > proceed beyond the point to which the error pertained (inclusion of a
> > header that does not exist in my arch). So I cannot test-compile the
> > driver on my arch and draw any conclusions from that beyond line 91.
> 
> What about you setup a cross-compiler and build for one of these architectures 
> where the driver is enabled?

That pretty easy IMHO : http://www.kernel.org/pub/tools/crosstool/
