From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [RFC PATCH bridge 1/5] bridge: Add vlan check to forwarding path
Date: Thu, 23 Aug 2012 22:58:32 +0200
Message-ID: <50369978.1050601@gmail.com>
References: <1345750195-31598-1-git-send-email-vyasevic@redhat.com> <1345750195-31598-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:47287 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934394Ab2HWU5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 16:57:17 -0400
Received: by eeil10 with SMTP id l10so454058eei.19
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 13:57:16 -0700 (PDT)
In-Reply-To: <1345750195-31598-2-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 23/08/2012 21:29, Vlad Yasevich a =C3=A9crit :
> -/* Don't forward packets to originating port or forwarding diasabled=
 */
> +/* Don't forward packets to originating port or forwarding diasabled=
=2E

While you work on this, feel free to fix the typo in disabled ^^^^^^^^^

	Nicolas.
