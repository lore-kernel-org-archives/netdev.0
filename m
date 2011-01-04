From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 #2 00/08] r8169 driver updates
Date: Tue, 04 Jan 2011 11:38:32 -0800 (PST)
Message-ID: <20110104.113832.179923880.davem@davemloft.net>
References: <20110104010716.GA5957@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hayeswang@realtek.com, benh@debian.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32938
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751378Ab1ADTiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 14:38:01 -0500
In-Reply-To: <20110104010716.GA5957@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Tue, 4 Jan 2011 02:07:16 +0100

> The following series adds on top of the previous one :
> - missing TxPacketMax and FW_LOADER (Ben Hutchings)
> - wrong OCPDR_GPHY_REG offset and mask.
>   Hayes, are you ok with this one ?
> 
> The RTL_GIGA_MAC_VER_27 changes suggested by Hayes at the end of the
> previous series are not included yet (feedback anyone ?).
> 
> The previous series included :
> - Hayes'firmware removal. The firmware is already included in linux-firmware.
> - my sauce to diminish the gap between the in-kernel r8169 driver
>   and Realtek's one(s).
> 
> The series is available as:
> git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git r8169-davem

I applied all of these patches, thanks Francois.

Because I am an idiot, I didn't notice you had a GIT tree with this
stuff prepared for me until after I pushed the patches out to
kernel.org :-/

Don't let this discourage you, using a GIT tree helps me a lot and I
just didn't expect it from you for whatever reason.  :-) So please
keep doing this and I will pull directly from your GIT tree next time.
