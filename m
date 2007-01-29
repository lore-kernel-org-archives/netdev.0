From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] zd1211rw: Reset device in the probe call
Date: Mon, 29 Jan 2007 07:56:11 -0500
Message-ID: <20070129125611.GA7034@tuxdriver.com>
References: <20070129010015.CA9397B409F@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kune@deine-taler.de
To: Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3666 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751387AbXA2N1g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 08:27:36 -0500
Content-Disposition: inline
In-Reply-To: <20070129010015.CA9397B409F@zog.reactivated.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 29, 2007 at 01:00:15AM +0000, Daniel Drake wrote:
> From: Ulrich Kunitz <kune@deine-taler.de>
> 
> This resets the device in the probe call. It does work with
> 2.6.19.2 including the softmac patches. It might fix the
> reboot/reset problems a lot of people reported.

Looks like you sent this one twice.  Is this just a duplicate?
Or did you mean to send a different patch?

John
-- 
John W. Linville
linville@tuxdriver.com
