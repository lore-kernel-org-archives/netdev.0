From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: stmmac: what happened to IFF_UNICAST_FLT
Date: Tue, 03 Apr 2012 14:52:50 +0200
Message-ID: <4F7AF2A2.3080106@st.com>
References: <4F7ADBAF.1030204@blackshift.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Rayagond Kokatanur <rayagond@vayavyalabs.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Marc Kleine-Budde <mkl@blackshift.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:59996 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751841Ab2DCMyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 08:54:20 -0400
In-Reply-To: <4F7ADBAF.1030204@blackshift.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/3/2012 1:14 PM, Marc Kleine-Budde wrote:
> Hello,
> 
> I think in patch "bfab27a stmmac: add the experimental PCI support" the
> flag IFF_UNICAST_FLT was lost, when the function
> stmmac_mac_device_setup() was moved around.

Hello Marc

I'm looking at this and I'll let you know.
In case of there is the issue, I'll fix and include it in the driver
updates (currently under review in the mailing list). If you have the
fix so I can include yours.

Regards
Peppe

> regards, Marc
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
