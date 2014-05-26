From: Gioacchino Mazzurco <gmazzurco89@gmail.com>
Subject: Re: Linux 802.1ad VLAN unexpected beaviour
Date: Mon, 26 May 2014 13:13:02 -0700 (PDT)
Message-ID: <3114248.zrbW3Trv4z@vaio-gio>
References: <2537748.74g6mjFNSk@vaio-gio> <53839C4D.5040000@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:55216 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218AbaEZUNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2014 16:13:07 -0400
Received: by mail-we0-f171.google.com with SMTP id w62so8447879wes.2
        for <netdev@vger.kernel.org>; Mon, 26 May 2014 13:13:04 -0700 (PDT)
In-Reply-To: <53839C4D.5040000@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 26 May 2014 21:55:57 Daniel Borkmann wrote:
> I think, as we already had a similar discussion on this topic on netdev,
> it's a libpcap problem, not a kernel one. See also the thread:
> 
>    http://lists.openwall.net/netdev/2014/04/14/19


After doing some more tests trying to verify your suggestion seems you are 
right :)

Many Thanks!
