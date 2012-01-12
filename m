From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: brcm80211 breakage..
Date: Wed, 11 Jan 2012 17:58:10 -0800
Message-ID: <CA+55aFw6n6dCW3KXXmSNBj=zqaWHyP9+8vYKDHTYqnKfhx8VzQ@mail.gmail.com>
References: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com>
 <4F0D6806.4080201@broadcom.com> <CA+55aFxzFKkUPSCU6Wr_FBPd6NFPeTctGR0kpqYJJ8fcw+ck7w@mail.gmail.com>
 <CA+55aFw7TdNzNi86cwF4o6xSWnbKuPS5CuhdbChzoboNw_1-Tw@mail.gmail.com>
 <4F0DC030.6090500@lwfinger.net> <CA+55aFyAX_OdE7yNp1vM1AmywrYZ9Pvr0EX47jNQciZKOQUQHg@mail.gmail.com>
 <4F0E3B7E.8040005@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Arend van Spriel <arend@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	=?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45865 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890Ab2ALB6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2012 20:58:32 -0500
Received: by wgbds12 with SMTP id ds12so1238279wgb.1
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2012 17:58:31 -0800 (PST)
In-Reply-To: <4F0E3B7E.8040005@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 11, 2012 at 5:46 PM, Larry Finger <Larry.Finger@lwfinger.net> wrote:
>
> What is the PCI ID for your device?

You can decode it from the lspci output posted in another email in
this thread, but it's basically 14e4:4353 (rev 01).

                     Linus
