From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: IRQF_SAMPLE_RANDOM question...
Date: Wed, 08 Apr 2009 17:16:06 -0600
Message-ID: <49DD3036.4020107@nortel.com>
References: <200904061430.26276.rgetz@blackfin.uclinux.org> <1239116251.14392.133.camel@calx> <a24804730904071439g4cc1779bi1ebaf814d370708c@mail.gmail.com> <200904071830.38081.rgetz@blackfin.uclinux.org> <2c6601c9b894$756e4000$f9b5a8c0@pii350>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Robin Getz <rgetz@blackfin.uclinux.org>,
	Chris Peterson <cpeterso@cpeterso.com>,
	Matt Mackall <mpm@selenic.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Gilles Espinasse <g.esp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04e.nortel.com ([47.129.242.56]:53022 "EHLO
	zcars04e.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754775AbZDHXQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 19:16:27 -0400
In-Reply-To: <2c6601c9b894$756e4000$f9b5a8c0@pii350>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gilles Espinasse wrote:

> Readme say :
> "This daemon attempts to collect real randomness from fluctuations of
> high-frequency clocks on a PC's mainboard. The basic assumption is that
> mainboard and CPU are clocked by two separate physical clocks."

> How large is this basic assumption true, on x86, on other arch?

Isn't the cpu frequency normally a phase-locked multiple of the 
mainboard bus frequency?

Chris
