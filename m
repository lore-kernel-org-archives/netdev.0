From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH 2/2] kaweth: fix oops upon failed memory allocation
Date: Wed, 17 Aug 2016 15:33:30 +0200
Message-ID: <1471440810.3705.9.camel@suse.com>
References: <1471427969-2355-1-git-send-email-oneukum@suse.com>
	 <1471427969-2355-2-git-send-email-oneukum@suse.com>
	 <87ziobk03e.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, stern@rowland.harvard.edu,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45198 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751495AbcHQNdd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Aug 2016 09:33:33 -0400
In-Reply-To: <87ziobk03e.fsf@miraculix.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-08-17 at 15:15 +0200, Bjørn Mork wrote:
> Oliver Neukum <oneukum@suse.com> writes:

> Eh, that should be "goto err_free_netdev;", shouldn't it?

Right, thanks. Fixed version coming up.

	Regards
		Oliver
