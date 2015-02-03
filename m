From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH] net: ipv6: Make address flushing on ifdown optional -
 v2
Date: Mon, 02 Feb 2015 17:11:56 -0700
Message-ID: <54D0124C.70202@gmail.com>
References: <1422504065-17445-1-git-send-email-dsahern@gmail.com> <20150203001057.3e0e22b2@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Hannes Frederic Sowa <hannes@redhat.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:50367 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752461AbbBCAL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 19:11:58 -0500
Received: by mail-ig0-f171.google.com with SMTP id h15so6398041igd.4
        for <netdev@vger.kernel.org>; Mon, 02 Feb 2015 16:11:57 -0800 (PST)
In-Reply-To: <20150203001057.3e0e22b2@uryu.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/2/15 4:10 PM, Stephen Hemminger wrote:
> Checkpatch complains about space before tab, which could be your
> mailer mangling the patch.

Yes, found that a couple of days ago. I use 'git send-email' to send the 
patches, and I have a pre-commit hook to run checkpatch.pl. Perhaps I 
goofed something in the recent latptop transitions.

>
> This should probably go into the netconf netlink message as well.
>

Not sure I understand this point. Can you point me to a code reference 
to look up?

Though that did remind me that I should add a blurb in 
Documentation/networking/ip-sysctl.txt.

David
