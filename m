From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] phylib: mdio-ofgpio ---> mdio-gpio
Date: Fri, 31 Oct 2008 10:26:11 -0700
Message-ID: <200810311026.12585.david-b@pacbell.net>
References: <20081031155335.19905.14186.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org,
	Laurent Pinchart <laurentp@cse-semaphore.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Mike Frysinger <vapier.adi@gmail.com>
To: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp121.sbc.mail.sp1.yahoo.com ([69.147.64.94]:28832 "HELO
	smtp121.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751267AbYJaR0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 13:26:15 -0400
In-Reply-To: <20081031155335.19905.14186.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 31 October 2008, Paulius Zaleckas wrote:
> - if NO_IRQ is not defined define it to 0

Better yet, stop using that symbol entirely...

