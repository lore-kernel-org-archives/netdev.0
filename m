From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH] nfs: fix dead code of ipv6_addr_scope
Date: Sat, 21 Dec 2013 09:17:07 +0100
Message-ID: <20131221081706.GA11689@omega>
References: <1387600744-11366-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	werner@almesberger.net
To: Trond.Myklebust@netapp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:35349 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166Ab3LUIRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Dec 2013 03:17:14 -0500
Content-Disposition: inline
In-Reply-To: <1387600744-11366-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I saw right now file "./net/sctp/ipv6.c" in function sctp_v6_scope has
the same issue.

- Alex
