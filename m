From: ratheesh k <ratheesh.ksz@gmail.com>
Subject: Re: iptables NEW or SYN
Date: Thu, 13 May 2010 20:51:55 +0530
Message-ID: <AANLkTilBAxOHBF_pZbaDDFnnUXaVVqm-45csjEI3ze1U@mail.gmail.com>
References: <hsgu5c$d8c$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Netfilter mailing list <netfilter@vger.kernel.org>
To: Markus Feldmann <feldmann_markus@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:45591 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752179Ab0EMPV4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 11:21:56 -0400
In-Reply-To: <hsgu5c$d8c$1@dough.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 13, 2010 at 6:47 PM, Markus Feldmann <feldmann_markus@gmx.d=
e> wrote:
> Hi All,
>
> i am still experiment with iptables and the state extension. Some of =
my
> rules shall catch packets with the state NEW, but it doesn't catch al=
l
> packets. Sometimes there are packets that have the SYN Flag set which=
 go
> through my rules with the state NEW.
>
> Any idea why?
> I thought SYN is included in the state NEW, is that wrong?
>
> What is the difference between SYN and NEW?
>
> regards Markus
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>

Please use  netfilter-users list advise of  experts in netfilter  .
-Ratheesh .
