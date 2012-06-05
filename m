From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH net-next 5/5] gianfar_ethtool: coding style and whitespace cleanups
Date: Tue, 05 Jun 2012 12:54:34 +0200
Message-ID: <4550590.BhQA539plh@flexo>
References: <4FCD084D.6020408@computer.org> <20120605.051437.1378262604943296071.davem@davemloft.net> <4FCDE447.3030103@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, b06378@freescale.com,
	joe@perches.com, netdev@vger.kernel.org
To: Jan Ceuleers <jan.ceuleers@computer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:34104 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761883Ab2FEK4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 06:56:48 -0400
Received: by eaak11 with SMTP id k11so1480817eaa.19
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2012 03:56:47 -0700 (PDT)
In-Reply-To: <4FCDE447.3030103@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tuesday 05 June 2012 12:49:43 Jan Ceuleers wrote:
> On 06/05/2012 11:14 AM, David Miller wrote:
> > From: Jan Ceuleers <jan.ceuleers@computer.org>
> > Date: Tue, 05 Jun 2012 07:54:29 +0200
> > 
> >> So your build environment happens to be one of powerpc, alpha or mips,
> >> does it?
> > 
> > No, I get those errors you posted too.
> > 
> > But like I said, you simply IGNORE THEM, and look for newly introduced
> > errors and warnings.
> 
> David,
> 
> The error I quoted was a fatal error, meaning that compilation did not
> proceed beyond the point to which the error pertained (inclusion of a
> header that does not exist in my arch). So I cannot test-compile the
> driver on my arch and draw any conclusions from that beyond line 91.

What about you setup a cross-compiler and build for one of these architectures 
where the driver is enabled?

> 
> I really wanted to make a modest contribution with this patch set, and
> it seems I've failed miserably due to the amount of other people's
> bandwidth that I'm consuming...
> 
> Jan
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
