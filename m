From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH][NET] several cleanups and bugfixes for fec.c: prevent
 dobule restart of interface on FDX/HDX change
Date: Tue, 6 Dec 2011 15:24:29 +0000
Message-ID: <1323185069.7454.263.camel@deadeye>
References: <cover.1323163127.git.LW@KARO-electronics.de>
	 <0b92136d69e509a6ce49b526e1834f0ec90b04a4.1323163127.git.LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Shawn Guo <shawn.guo@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Lothar =?ISO-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:22813 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753702Ab1LFPYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 10:24:37 -0500
In-Reply-To: <0b92136d69e509a6ce49b526e1834f0ec90b04a4.1323163127.git.LW@KARO-electronics.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You shouldn't repeat the subject of the whole series in the subject of
each patch.  Just put the name of the component you're changing (in this
case, 'fec: prevent dobule restart of interface on FDX/HDX change').

(Nitpick: typo in 'double'.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
