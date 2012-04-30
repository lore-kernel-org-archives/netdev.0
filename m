From: =?ISO-8859-1?Q?Niccol=F2_Belli?= <darkbasic@linuxsystems.it>
Subject: Re: [RFT] sky2: fix status length check on older chips
Date: Mon, 30 Apr 2012 20:23:35 +0200
Message-ID: <4F9ED8A7.3050302@linuxsystems.it>
References: <4F9AFE4E.8010108@linuxsystems.it> <20120427134127.6d536a96@nehalam.linuxnetplumber.net> <20120427135514.48b03ce8@nehalam.linuxnetplumber.net> <4F9B2641.9070209@linuxsystems.it> <20120427194635.0b65b0ee@nehalam.linuxnetplumber.net> <4F9BC59D.80304@linuxsystems.it> <20120430091952.402567ad@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxsystems.it ([2.119.245.41]:34920 "EHLO
	mail.linuxsystems.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756362Ab2D3SWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 14:22:38 -0400
In-Reply-To: <20120430091952.402567ad@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Il 30/04/2012 18:19, Stephen Hemminger ha scritto:
> Still your laptop will receive vlan frames (even just broadcasts).

Right, so I tested it with a point2point connection: I have the very=20
same problem.

Niccol=F2
