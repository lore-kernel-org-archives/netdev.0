From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 47021] New: kernel panic with l2tpv3 & mtu > 1500
Date: Tue, 04 Sep 2012 22:57:14 +0200
Message-ID: <1346792234.13121.93.camel@edumazet-glaptop>
References: <20120904090756.71b34feb@nehalam.linuxnetplumber.net>
	 <1346788334.13121.82.camel@edumazet-glaptop>
	 <20120904125458.7d97ec38@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, a1bert@atlas.cz
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:58294 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757043Ab2IDU52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2012 16:57:28 -0400
Received: by qaas11 with SMTP id s11so3644068qaa.19
        for <netdev@vger.kernel.org>; Tue, 04 Sep 2012 13:57:28 -0700 (PDT)
In-Reply-To: <20120904125458.7d97ec38@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-09-04 at 12:54 -0700, Stephen Hemminger wrote:

> 
> I guess nobody ever looked inside this code. That seems like an obvious bug.

It seems that l2tp lacks ECN support as well.
