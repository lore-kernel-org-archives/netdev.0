From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 1/2] rfkill - Add rfkill driver to misc input devices
Date: Wed, 16 Aug 2006 19:15:35 +0200
Message-ID: <20060816191535.29da5095@griffin.suse.cz>
References: <200608081630.12467.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:39050 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751131AbWHPRPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 13:15:37 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200608081630.12467.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 8 Aug 2006 16:30:12 +0200, Ivo van Doorn wrote:
> This will add the rfkill driver to the input/misc section of the kernel.
> rfkill is usefull for newtwork devices that contain a hardware button
> to enable or disable the radio.
> With rfkill a generic interface is created for the network drivers,
> as well as providing a  uniform way for userspace to listen
> to the hardware button events.

You need to send this patch to lkml and to input subsystem maintainer.

 Jiri

-- 
Jiri Benc
SUSE Labs
