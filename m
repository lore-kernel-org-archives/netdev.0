From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-2.6.26] netlink: make socket filters work on netlink
Date: Wed, 02 Apr 2008 08:01:07 -0400
Message-ID: <1207137667.4451.143.camel@localhost>
References: <47EAAFEC.6000805@trash.net> <20080331123311.64e4ca37@extreme>
	 <47F13E43.2040404@trash.net>
	 <20080331.130757.199769025.davem@davemloft.net>
	 <47F1467F.2080407@trash.net> <1207000143.4424.167.camel@localhost>
	 <47F22211.5080100@trash.net> <1207058646.4424.218.camel@localhost>
	 <47F35933.5080305@trash.net>  <20080402112103.GB20815@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.227]:53526 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752846AbYDBMBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 08:01:11 -0400
Received: by wx-out-0506.google.com with SMTP id h31so2811574wxd.4
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2008 05:01:10 -0700 (PDT)
In-Reply-To: <20080402112103.GB20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-02-04 at 13:21 +0200, Thomas Graf wrote:

> Probably fixable though.

One way "i fixed it" was removed by Alexey in commit:
28633514afd68afa77ed2fa34fa53626837bf2d5

Note: Alexey is right of course.

cheers,
jamal

