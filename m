From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2 net-next 13/13] ipv6: route: per route IP tunnel
 metadata via lightweight tunnel
Date: Wed, 19 Aug 2015 20:03:12 +0200
Message-ID: <20150819180312.GD5564@pox.localdomain>
References: <cover.1439978875.git.jbenc@redhat.com>
 <0694438feae2730b0bd3354b5e977bc9d6a5a192.1439978875.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:36079 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751721AbbHSUle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 16:41:34 -0400
Received: by wicja10 with SMTP id ja10so129462077wic.1
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 13:41:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <0694438feae2730b0bd3354b5e977bc9d6a5a192.1439978875.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/15 at 12:10pm, Jiri Benc wrote:
> Allow specification of per route IP tunnel instructions also for IPv6.
> This complements commit 3093fbe7ff4b ("route: Per route IP tunnel metadata
> via lightweight tunnel").
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
