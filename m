From: Martin Volf <martin.volf.42@gmail.com>
Subject: Re: [RFT] bridge: checksum not updated after pull
Date: Tue, 15 Nov 2011 20:51:44 +0100
Message-ID: <CAM1AHpQsYz=y8m_RSzfPkGXGFZ8rQQE0Q+pmfbRb6K0v-jQ91w@mail.gmail.com>
References: <CAM1AHpSuruDx3CxzK=Med0iyxxwu7wxgRZib7yhBMiCVKXqzeA@mail.gmail.com>
	<4EC23EE7.2010606@intel.com>
	<20111115100914.0c9540be@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Yan, Zheng" <zheng.z.yan@intel.com>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"wcang@sfc.wide.ad.jp" <wcang@sfc.wide.ad.jp>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:57221 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757386Ab1KOTvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 14:51:46 -0500
Received: by fagn18 with SMTP id n18so796012fag.19
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2011 11:51:45 -0800 (PST)
In-Reply-To: <20111115100914.0c9540be@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15 November 2011 19:09, Stephen Hemminger <shemminger@vyatta.com> wrote:
> I think this is what is necessary, please test.
...

Hello,

with the patch on top of 3.1.1 I no longer get the "hw csum failure"
message. I don't know how to test IPv6 multicast, but IPv6 ND and
SLAAC is correctly passing through the bridge.

Thanks!

Martin Volf
