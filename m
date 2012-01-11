From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: brcm80211 breakage..
Date: Wed, 11 Jan 2012 07:05:38 -0800
Message-ID: <CA+55aFxzFKkUPSCU6Wr_FBPd6NFPeTctGR0kpqYJJ8fcw+ck7w@mail.gmail.com>
References: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com>
 <4F0D6806.4080201@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	=?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>,
	Larry Finger <Larry.Finger@lwfinger.net>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:62890 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756905Ab2AKPGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2012 10:06:00 -0500
Received: by wibhm14 with SMTP id hm14so430865wib.19
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2012 07:05:59 -0800 (PST)
In-Reply-To: <4F0D6806.4080201@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 11, 2012 at 2:44 AM, Arend van Spriel <arend@broadcom.com> wrote:
>
> My theory is that the BAR window is not mapped to a valid address. Could
> you try to revert the following commit:

Sadly, that one makes no difference. I'll enable BRCM/BCMA debugging
and see if that gives any more information, but will be unable to do
much for the next few hours, so it will likely not be until this
afternoon.

                            Linus
