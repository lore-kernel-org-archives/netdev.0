From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [linux-usb-devel] [PATCH RFC] ZyDAS ZD1211 USB-WLAN driver
Date: Sat, 10 Jun 2006 13:40:21 +0100
Message-ID: <448ABDB5.6040803@gentoo.org>
References: <44817083.508@gentoo.org> <200606031951.09135.oliver@neukum.org> <4481E497.2000505@gentoo.org> <200606040025.32275.oliver@neukum.org> <20060610112306.GA19198@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta08-winn.ispmail.ntl.com ([81.103.221.48]:46371 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1751503AbWFJMjE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jun 2006 08:39:04 -0400
To: Oliver Neukum <oliver@neukum.org>, Daniel Drake <dsd@gentoo.org>,
	linux-usb-devel@lists.sourceforge.net,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
In-Reply-To: <20060610112306.GA19198@p15091797.pureserver.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ulrich Kunitz wrote:
> Not so fast, because I don't know what to fix.

I am working on it. A couple more mails to Herbert Xu should clarify it, 
then I'll post a patch. On first glance I was quite worried that there 
are a lot of potential races, but now I think there will only be a few 
places.

Daniel
