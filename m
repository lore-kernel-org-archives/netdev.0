From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/2] net: Add RX queue weights
Date: Fri, 11 Feb 2011 21:32:54 -0800
Message-ID: <AANLkTikqEDDcM626qaJbKcJ8zO6gm+76DkV-Na5NrgHD@mail.gmail.com>
References: <alpine.DEB.2.00.1102111552090.2793@pokey.mtv.corp.google.com>
	<4D560350.5080002@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:59586 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097Ab1BLFc7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Feb 2011 00:32:59 -0500
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p1C5Wul0003825
	for <netdev@vger.kernel.org>; Fri, 11 Feb 2011 21:32:57 -0800
Received: from pxi2 (pxi2.prod.google.com [10.243.27.2])
	by kpbe13.cbf.corp.google.com with ESMTP id p1C5Wtis029159
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 11 Feb 2011 21:32:55 -0800
Received: by pxi2 with SMTP id 2so989352pxi.40
        for <netdev@vger.kernel.org>; Fri, 11 Feb 2011 21:32:55 -0800 (PST)
In-Reply-To: <4D560350.5080002@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Doesn't ethtool -X already do this? =A0With the added benefit that et=
htool doesn't need each driver to provide its own weight handling arith=
metic.
>
Indeed.  Patches withdrawn.

Tom
