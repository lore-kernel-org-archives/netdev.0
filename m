From: "Loke, Chetan" <Chetan.Loke@netscout.com>
Subject: RE: [RFC] Enhance dev_ioctl to return <hwaddr>:<if_name::if_index>  mapping
Date: Fri, 16 Jul 2010 14:12:24 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B90C55C202@nsmail.netscout.com>
References: <AANLkTinxLy2noL0GcZyVtMsEndxseCr6kkxuvyBNIfHr@mail.gmail.com><1279300205.2097.9.camel@achroite.uk.solarflarecom.com> <20100716110407.316eb8f1@s6510>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Chetan Loke" <chetanloke@gmail.com>, <netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@vyatta.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod6og101.obsmtp.com ([64.18.1.181]:58439 "HELO
	exprod6og101.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S966021Ab0GPSTh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 14:19:37 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20100716110407.316eb8f1@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> Sent: July 16, 2010 2:04 PM
 
> The additional API is not needed. It is trivial to find address for
> device and do reverse mapping. Either with ioctl's 
Sorry, I might have missed it. But which ioctl would that be?

> or /sys/class/net/XXX/addr
So, is reading /sys/ nodes preferred over get-calls?

regards
Chetan Loke
