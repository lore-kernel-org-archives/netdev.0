From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH 3/5] Rename support library for geneve
Date: Fri, 03 Apr 2015 17:54:02 +0200
Message-ID: <551EB79A.4070707@6wind.com>
References: <1428002227-11636-1-git-send-email-linville@tuxdriver.com> <1428002227-11636-4-git-send-email-linville@tuxdriver.com> <CAHA+R7Op9inHY=CvyyqgK4v7=xxntAPmZBzBYg27hxcKFF7H6A@mail.gmail.com> <20150403144032.GB31348@tuxdriver.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: "John W. Linville" <linville@tuxdriver.com>,
	Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:36210 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbbDCPyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 11:54:05 -0400
Received: by wizk4 with SMTP id k4so47789949wiz.1
        for <netdev@vger.kernel.org>; Fri, 03 Apr 2015 08:54:04 -0700 (PDT)
In-Reply-To: <20150403144032.GB31348@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/04/2015 16:40, John W. Linville a =E9crit :
[snip]
> Honestly, this name change seems like the simplest and least awkward
> choice to me.  But, I am open to suggestions...
There is already some files named '_core.c' under net/ipv4 and net/ipv6=
=2E
What about geneve_core.c ?

My two cents,
Nicolas
