From: Patrick McHardy <kaber@trash.net>
Subject: Re: Possible 2.6.22 -> 2.6.23 HTB regression?
Date: Wed, 10 Oct 2007 14:38:29 +0200
Message-ID: <470CC7C5.4070204@trash.net>
References: <20071010123222.M71635@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60316 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753250AbXJJMlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 08:41:49 -0400
In-Reply-To: <20071010123222.M71635@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denys wrote:
>>>>>here is try to switch clocksource to acpi_pm
> 
> 
> Time: acpi_pm clocksource has been installed.
> Clockevents: could not switch to one-shot mode: lapic is not functional.
> Could not switch to high resolution mode on CPU 0


What does /proc/net/psched contain?
