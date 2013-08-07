From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [PATCH 2/5] net: syncookies: export
 cookie_v4_init_sequence/cookie_v4_check
Date: Wed, 7 Aug 2013 22:03:08 +0200
Message-ID: <20130807220308.271dde51@redhat.com>
References: <1375897371-18430-1-git-send-email-kaber@trash.net>
	<1375897371-18430-3-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, mph@one.com, as@one.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43951 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933046Ab3HGUDR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Aug 2013 16:03:17 -0400
In-Reply-To: <1375897371-18430-3-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  7 Aug 2013 19:42:48 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Extract the local TCP stack independant parts of
> tcp_v4_init_sequence() and cookie_v4_check() and export them for use
> by the upcoming SYNPROXY target.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
