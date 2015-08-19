From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2 net-next 11/13] vxlan: metadata based tunneling for
 IPv6
Date: Wed, 19 Aug 2015 19:57:27 +0200
Message-ID: <20150819175727.GB5564@pox.localdomain>
References: <cover.1439978875.git.jbenc@redhat.com>
 <d07be028321109caf87da0cf00f3ae9c9ac94f63.1439978875.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:35420 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752318AbbHSUja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 16:39:30 -0400
Received: by wicne3 with SMTP id ne3so129995816wic.0
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 13:39:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <d07be028321109caf87da0cf00f3ae9c9ac94f63.1439978875.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/15 at 12:10pm, Jiri Benc wrote:
> Support metadata based (formerly flow based) tunneling also for IPv6.
> This complements commit ee122c79d422 ("vxlan: Flow based tunneling").
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
