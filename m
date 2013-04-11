From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Thu, 11 Apr 2013 18:19:16 +0800
Message-ID: <CACVXFVNn9MQr6JLdin=u642Jb-2ZPfVk8YaBmNdhU0_2e7WJqQ@mail.gmail.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<1365625850.22411.1.camel@dcbw.foobar.com>
	<CACVXFVNKSszw+3VnM3hwepbTHh3gvjC+pG2SL_OsVm+1SqrNzQ@mail.gmail.com>
	<2552222.23e5DWG2Z9@linux-5eaq.site>
	<87txndwkx1.fsf@nemi.mork.no>
	<CACVXFVMW2Dosr0FAKCvxgUFQKmwbduiC+HqmzS1tsvAHu=G8Kg@mail.gmail.com>
	<87ppy1wfhq.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.org>, Dan Williams <dcbw@redhat.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f179.google.com ([209.85.220.179]:54058 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765085Ab3DKKTR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 06:19:17 -0400
In-Reply-To: <87ppy1wfhq.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 11, 2013 at 6:04 PM, Bj=F8rn Mork <bjorn@mork.no> wrote:
> Ming Lei <tom.leiming@gmail.com> writes:
>
> Again: What problem are you attempting to solve by removing the
> mem_flags from the API?

It is not about removing anything, we are discussing one new API
(include the parameters) to be introduced.

Thanks,
--=20
Ming Lei
