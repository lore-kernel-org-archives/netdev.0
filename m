From: Pavel Simerda <psimerda@redhat.com>
Subject: iproute2 documentation
Date: Mon, 16 Mar 2015 06:54:32 -0400 (EDT)
Message-ID: <486332040.2425794.1426503272511.JavaMail.zimbra@redhat.com>
References: <1988820225.2425618.1426503091224.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Kenyon Ralph <kenyon@kenyonralph.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:43707 "EHLO
	mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752932AbbCPKyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 06:54:35 -0400
In-Reply-To: <1988820225.2425618.1426503091224.JavaMail.zimbra@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I just stepped on your manpage commit that got apparently lost in history as
the current manpage doesn't for example include the lifetime description. Let
me know if I should prepare a new documentation patch for the current git master
or you want to handle it yourself.

commit 43d29f782f12d6212ea3717a3a47b0036474a67c
Author: Kenyon Ralph <kenyon@kenyonralph.com>
Date:   Thu Mar 15 14:39:12 2012 -0700

    Update ip address manual page
    
    * update synopsis to match "ip address help" output
    * specify IPv4, since "IP" is ambiguous
    * remove deprecated site scope
    * document lifetimes, home, and nodad
    * update wording to make sense since page was split from the ip(8) page
    * git rid of extra spaces

Cheers,

Pavel
