From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: iproute2: proper detection of libxtables position and flags
Date: Tue, 3 Jan 2012 23:18:07 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1201032303470.9394@frira.zrqbmnf.qr>
References: <alpine.LNX.2.01.1112312317220.24158@frira.zrqbmnf.qr> <20120103134719.414ae3d0@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seven.medozas.de ([188.40.89.202]:57907 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754891Ab2ACWSJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jan 2012 17:18:09 -0500
In-Reply-To: <20120103134719.414ae3d0@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 2012-01-03 22:47, Stephen Hemminger wrote:

>On Sat, 31 Dec 2011 23:17:56 +0100 (CET)
>Jan Engelhardt <jengelh@medozas.de> wrote:
>
>> From: Jan Engelhardt <jengelh@medozas.de>
>> Date: 2011-09-24 23:37:34.405739159 +0200
>> Upstream: not sent yet
>> 
>> Any tests involving iptables _MUST_ utilize pkg-config to find the
>> proper locations of the installation. 
>> 
>
>Will this work for all distros? Is this backwards compatiable?

The pkg-config file was shipped since the start, and it is the
one supported variant to find/link the lib.
