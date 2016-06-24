From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [iproute PATCH v3 0/6] Big C99 style initializer rework
Date: Fri, 24 Jun 2016 15:12:20 +0200
Message-ID: <576D31B4.902@6wind.com>
References: <1466703254-5174-1-git-send-email-phil@nwl.cc>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Julien Floret <julien.floret@6wind.com>, netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>, Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35914 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387AbcFXNMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 09:12:25 -0400
Received: by mail-wm0-f50.google.com with SMTP id f126so22024190wma.1
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 06:12:24 -0700 (PDT)
In-Reply-To: <1466703254-5174-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/06/2016 19:34, Phil Sutter a =C3=A9crit :
> This is v3 of my C99-style initializer related patch series. The chan=
ges
> since v2 are:
Compile-tested with a gcc 4.4.7.


Regards,
Nicolas
