From: David Miller <davem@redhat.com>
Subject: Re: pull-request: can 2015-03-09
Date: Mon, 09 Mar 2015 15:41:22 -0400 (EDT)
Message-ID: <20150309.154122.193616220434701160.davem@redhat.com>
References: <1425893781-10867-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49444 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751469AbbCITl0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2015 15:41:26 -0400
In-Reply-To: <1425893781-10867-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Mon,  9 Mar 2015 10:36:15 +0100

> this is a pull request for net/master for the 4.0 release cycle, it consists of
> 6 patches:
> 
> A patch by Oliver Hartkopp fixes a long outstanding bug in the infrastructure,
> which leads to skb_under_panics when CAN interfaces are used by AF_PACKET
> sockets e.g. by dhclient. Stephane Grosjean contributes a patch for the
> peak_usb driver which adds a missing initialization. Two patches by Ahmed S.
> Darwish fix problems in the kvaser_usb driver. Followed by two patches by
> myself, updating the MAINTAINERS file.

Applied, thanks Marc.
