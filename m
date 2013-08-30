From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] net: usbnet: update addr_assign_type if appropriate
Date: Fri, 30 Aug 2013 21:19:41 +0200
Message-ID: <871u5bx9yq.fsf@nemi.mork.no>
References: <87d2ovxcrx.fsf@nemi.mork.no>
	<20130830.144118.1671225313340653567.davem@davemloft.net>
	<8761unxb1s.fsf@nemi.mork.no>
	<20130830.151400.1400969856580136990.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org, oneukum@suse.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:59174 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754278Ab3H3TTt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 15:19:49 -0400
In-Reply-To: <20130830.151400.1400969856580136990.davem@davemloft.net> (David
	Miller's message of "Fri, 30 Aug 2013 15:14:00 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> I was hoping to get this fix, via the series.  When we have multiple =
instances
> of the same bug it makes no sense to just fix one, especially now tha=
t you're
> done the work to do all of them already.

I see.  Sorry for not catching that earlier.


Bj=C3=B8rn
