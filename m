From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Bonding : Monitoring of 4965 wireless card
Date: Wed, 9 Jan 2008 12:02:05 -0500
Message-ID: <20080109170205.GB3204@tuxdriver.com>
References: <802012.38504.qm@web25708.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: patnel972-linux@yahoo.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4165 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752560AbYAIRUD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2008 12:20:03 -0500
Content-Disposition: inline
In-Reply-To: <802012.38504.qm@web25708.mail.ukl.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 09, 2008 at 09:00:05AM +0000, patnel972-linux@yahoo.fr wrote:
> Hi,
> 
> I want to make a bond with my wireless card. The ipw driver create two
>  interfaces (wlan0 and wmaster0). When i switch the rf_kill button,
>  ifplug detect wlan0 unplugged but not wmaster0. If i down wlan0 (while
>  rf_kil ), bonding detect the inactivity when i up the interface.
> 
> Have you some idea where is the problem? the driver or the miimon of
>  the module?
> 
> my module parameters mode=1 miimon=100 primary eth0

I'm not sure I understand your description...what are you trying to do?
How exactly is it failing?

John
-- 
John W. Linville
linville@tuxdriver.com
