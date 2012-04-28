From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFT] sky2: fix status length check on older chips
Date: Fri, 27 Apr 2012 19:46:35 -0700
Message-ID: <20120427194635.0b65b0ee@nehalam.linuxnetplumber.net>
References: <4F9AFE4E.8010108@linuxsystems.it>
	<20120427134127.6d536a96@nehalam.linuxnetplumber.net>
	<20120427135514.48b03ce8@nehalam.linuxnetplumber.net>
	<4F9B2641.9070209@linuxsystems.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?B?TmljY29s8g==?= Belli <darkbasic@linuxsystems.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58078 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752445Ab2D1Cqi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2012 22:46:38 -0400
In-Reply-To: <4F9B2641.9070209@linuxsystems.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Are you using VLAN's? the whole problem report only applies if using VLAN
on old hardware.
