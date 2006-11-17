From: "Dmitry Torokhov" <dmitry.torokhov@gmail.com>
Subject: Re: [PATCH wireless-2.6-git] prism54: WPA/RSN support for fullmac cards
Date: Fri, 17 Nov 2006 16:02:31 -0500
Message-ID: <d120d5000611171302u110573b6y195220895ef61ba8@mail.gmail.com>
References: <200610031457.33215.chunkeey@web.de>
	 <200611172043.27588.chunkeey@web.de>
	 <d120d5000611171216y76098a6bv86cba96160fee0eb@mail.gmail.com>
	 <200611172153.50278.chunkeey@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.233]:36043 "EHLO
	hu-out-0506.google.com") by vger.kernel.org with ESMTP
	id S933623AbWKQVCd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 16:02:33 -0500
Received: by hu-out-0506.google.com with SMTP id 36so456502hui
        for <netdev@vger.kernel.org>; Fri, 17 Nov 2006 13:02:31 -0800 (PST)
To: "chunkeey@web.de" <chunkeey@web.de>
In-Reply-To: <200611172153.50278.chunkeey@web.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/17/06, chunkeey@web.de <chunkeey@web.de> wrote:
> >
> > The reason for me trying the patch is that the card locks up
> > frequently (the amber transmission light turns on stays this way).
>
> Do you get any fancy "mgt timeout ..." or something in dmesg, when
> the cards locks up? (include one, if you can, maybe syslog "saved" one)
>

I think I saw these before (with earlier kernels, can't tell you
exactly when it stopped as I don't pay much attention to versions - I
work off tip of Linus's tree and pull often) but now it looks like it
simply locks up. Maybe I don't wait long enough - I just simply eject
and inster the card back when I see it locked up.

-- 
Dmitry
