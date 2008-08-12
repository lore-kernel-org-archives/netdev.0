From: Marc Haber <mh+netdev@zugschlus.de>
Subject: Re: Need help with MCS7830 driver and 802.1q VLAN Tagging
Date: Tue, 12 Aug 2008 14:01:40 +0200
Message-ID: <20080812120140.GC22681@torres.zugschlus.de>
References: <20080807153617.GA4001@torres.zugschlus.de> <20080807170635.GC10471@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.68.41]:39149 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439AbYHLMBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 08:01:42 -0400
Content-Disposition: inline
In-Reply-To: <20080807170635.GC10471@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

On Thu, Aug 07, 2008 at 06:06:36PM +0100, Ben Hutchings wrote:
> This could be a general problem with USB Ethernet drivers, as usbnet.c
> doesn't seem to take account of VLAN header overhead.
> 
> Does the following help?

thanks for your quick answer. It'll be until next week when I'll be
near a VLAN-able setup and the MCS device again, but I'll report back.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190
