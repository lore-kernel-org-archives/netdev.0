From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [RFC] rt2400: fix breakage from API changes
Date: Fri, 1 Dec 2006 23:22:58 +0100
Message-ID: <200612012322.59283.IvDoorn@gmail.com>
References: <20061201215318.GC3370@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:54486 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1162109AbWLAWXO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Dec 2006 17:23:14 -0500
Received: by ug-out-1314.google.com with SMTP id 44so2549895uga
        for <netdev@vger.kernel.org>; Fri, 01 Dec 2006 14:23:13 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061201215318.GC3370@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> Here's my whack at fixing-up the rt2400pci driver to compile, since
> the recent API changes broke it.  This only covers that one driver,
> so lots more (albeit similar) work needs to be done to cover the
> other rt2x00 family drivers.
> 
> Ivo and Johannes, please take a quick look to see if I'm obviously
> missing something or handling something incorrectly.  I don't have
> the hardware in questions, so this is completely untested. :-)

Patch looks good.
I believe I could have a patchseries available next weekend (December 9th)
that will update rt2x00 to the latest cvs version.
Its been a while since my last patch series to the wireless-dev tree,
but that was because I was quite busy the last months.
I'll start working on the patchs series this week, so they should be done
at the end of the week. That should save you some time working on
unknown code ;) And will provide a version that has been well tested. :)

Ivo
