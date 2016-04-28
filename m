From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] drivers/net: add 6WIND SHULTI support
Date: Thu, 28 Apr 2016 14:00:17 +0200
Message-ID: <5721FB51.8070303@6wind.com>
References: <1461749838-4613-1-git-send-email-nicolas.dichtel@6wind.com>
 <20160427095615.GA27071@breakpoint.cc>
 <20160427151336.GB1962@nanopsycho.orion>
 <20160427.125506.1088576804354580011.davem@davemloft.net>
 <20160427100745.29976fbc@samsung9>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jiri@resnulli.us, fw@strlen.de, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35425 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752815AbcD1MAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 08:00:31 -0400
Received: by mail-wm0-f47.google.com with SMTP id e201so73784197wme.0
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 05:00:31 -0700 (PDT)
In-Reply-To: <20160427100745.29976fbc@samsung9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 27/04/2016 19:07, Stephen Hemminger a =E9crit :
[snip]
> Also it has a bunch of device specific generic netlink which was
> a red flag for me.
>=20
Ok, I will rework this part.
