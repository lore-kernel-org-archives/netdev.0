From: Antoine Reversat <a.reversat@gmail.com>
Subject: Re: [Bugme-new] [Bug 37172] New: Enabling 802.1q vlan causes some
 packets to be received with a vlan id of 64
Date: Tue, 14 Jun 2011 09:31:52 -0400
Message-ID: <BANLkTi=Omr+oe3nMiqVeS+8tiSJnxONbhQ@mail.gmail.com>
References: <bug-37172-10286@https.bugzilla.kernel.org/>
	<20110613164355.c4f7b7b2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:41741 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369Ab1FNNhS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 09:37:18 -0400
Received: by eyx24 with SMTP id 24so2012907eyx.19
        for <netdev@vger.kernel.org>; Tue, 14 Jun 2011 06:37:17 -0700 (PDT)
In-Reply-To: <20110613164355.c4f7b7b2.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 13, 2011 at 7:43 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> From which kernel version did we regress? =A0Was 2.6.38 OK?

I can confirm this bug is present in 2.6.38.6

I'll try and see if I can reproduce it on a 2.6.37
