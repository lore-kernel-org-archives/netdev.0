From: Oliver Neukum <oliver@neukum.org>
Subject: Re: zd1201 failure on sharp zaurus explained
Date: Tue, 30 May 2006 16:11:02 +0200
Message-ID: <200605301611.02984.oliver@neukum.org>
References: <20060530132054.GA9780@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: rpurdie@rpsys.net, lenz@cs.wisc.edu,
	kernel list <linux-kernel@vger.kernel.org>,
	Russell King <rmk@arm.linux.org.uk>,
	Netdev list <netdev@vger.kernel.org>,
	Jirka Lenost Benc <jbenc@suse.cz>, pe1rxq@amsat.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.kontent.de ([81.88.34.36]:55721 "EHLO Mail1.KONTENT.De")
	by vger.kernel.org with ESMTP id S932259AbWE3OPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 May 2006 10:15:22 -0400
To: Pavel Machek <pavel@suse.cz>
In-Reply-To: <20060530132054.GA9780@elf.ucw.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Dienstag, 30. Mai 2006 15:20 schrieb Pavel Machek:
> 2) usb problem, probably. Should not usb core detect that card
> requires too much juice and refuse to power it up?

Does your hub correctly report whether it is plugged in?

	Regards
		Oliver
