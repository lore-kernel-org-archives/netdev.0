From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] am79c961a: fix spin_lock usage
Date: Thu, 22 Jan 2009 22:34:12 +0000
Message-ID: <20090122223412.GB8137@n2100.arm.linux.org.uk>
References: <1232663382-10503-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.arm.linux.org.uk,
	Roel Kluin <12o3l@tiscali.nl>,
	Steven Rostedt <srostedt@redhat.com>, netdev@vger.kernel.org
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:52159 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753422AbZAVWf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 17:35:26 -0500
Content-Disposition: inline
In-Reply-To: <1232663382-10503-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 22, 2009 at 11:29:42PM +0100, Uwe Kleine-K=F6nig wrote:
> unrelated to that, with arm-linux-gnu-gcc 4.3.2 I get some warnings w=
hen
> compiling am79c961a.c:

Don't care about gcc 4.3.2 - it's broken for the ARM architecture.
