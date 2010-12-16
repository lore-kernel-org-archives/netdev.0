From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] e1000e: convert to stats64
Date: Thu, 16 Dec 2010 14:18:57 +0100
Message-ID: <1292505537.2883.111.camel@edumazet-laptop>
References: <1292358735-32089-1-git-send-email-fleitner@redhat.com>
	 <1292362173.2478.6.camel@edumazet-laptop>
	 <20101216123131.GA3070@redhat.com>
	 <1292503830.2883.92.camel@edumazet-laptop>
	 <20101216131021.GA20139@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Flavio Leitner <fleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55740 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449Ab0LPNTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 08:19:03 -0500
Received: by wwa36 with SMTP id 36so2415934wwa.1
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 05:19:02 -0800 (PST)
In-Reply-To: <20101216131021.GA20139@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 d=C3=A9cembre 2010 =C3=A0 11:10 -0200, Flavio Leitner a =C3=
=A9crit :

> Yes, but e1000_get_ethtool_stats() also calls it and doesn't do that.
> I could move the memset to the caller, but I thought it would be clea=
ner
> to leave where it is now.

Yes, no problem !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


