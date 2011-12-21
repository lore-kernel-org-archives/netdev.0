From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: stmmac: updating the driver to the Dec 2011 version and add the PCI
 support
Date: Wed, 21 Dec 2011 14:56:18 +0100
Message-ID: <4EF1E582.5050300@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Rayagond K <rayagond@vayavyalabs.com>,
	"David S. Miller" <davem@davemloft.net>
To: ML netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:53813 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750733Ab1LUN4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 08:56:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

This patches update the stmmac device driver to the latest version (Dec
2011) adding the experimental PCI support - thanks to the effort on
developing and testing done by Rayagond Kokatanur.

I'm sending the patches for both net and net-next repositories.

In the next updates, I hope in January, I will send the EEE and PTP
support (always thanks to Rayagond contribution).

In the end, the driver's documentation has been updated too.

Best Regards
Peppe
