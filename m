From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH 00/29] net: VRF support
Date: Fri, 06 Feb 2015 16:08:51 +0100
Message-ID: <54D4D903.7080006@6wind.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>	<20150205173334.08248382@uryu.home.lan> <54D4227B.6080709@gmail.com> <87r3u3vfpr.fsf@x220.int.ebiederm.org> <54D45C15.7090602@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:56888 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754279AbbBFPIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 10:08:54 -0500
Received: by mail-we0-f170.google.com with SMTP id q59so5404885wes.1
        for <netdev@vger.kernel.org>; Fri, 06 Feb 2015 07:08:53 -0800 (PST)
In-Reply-To: <54D45C15.7090602@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/02/2015 07:15, David Ahern a =E9crit :
[snip]
> Application code -- open source daemons -- can be modified to be VRF =
aware as
> needed. Kernel side VRF support would be made a CONFIG option that de=
faults off.
> The macros will ensure anything VRF related falls out, so server depl=
oyments
> would not be impacted.
Most of distributions enables all kernel options.
