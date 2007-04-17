From: Robin Getz <rgetz@blackfin.uclinux.org>
Subject: Re: [PATCH] CONFIG_PACKET_MMAP should depend on MMU
Date: Tue, 17 Apr 2007 14:30:20 -0400
Message-ID: <200704171430.21075.rgetz@blackfin.uclinux.org>
References: <200704091146.32346.rgetz@blackfin.uclinux.org> <200704101952.05380.rgetz@blackfin.uclinux.org> <6d6a94c50704170336l62fc9ael1e58197e6c3853ba@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: uaca@alumni.uv.es, bryan.wu@analog.com,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>, waltje@uwalt.nl.mugnet.org,
	netdev@vger.kernel.org, "Andrew Morton" <akpm@osdl.org>,
	"Linux Kernel" <linux-kernel@vger.kernel.org>
To: "Aubrey Li" <aubreylee@gmail.com>,
	"David Howells" <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail11.analog.com ([137.71.25.57]:29202 "EHLO
	nwd2mail11.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161371AbXDQS2g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 14:28:36 -0400
In-Reply-To: <6d6a94c50704170336l62fc9ael1e58197e6c3853ba@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue 17 Apr 2007 06:36, Aubrey Li pondered:
> Here, in the attachment I wrote a small test app. Please correct if
> there is anything wrong, and feel free to improve it.

Thanks. 

David - Does this give you what you need?
