From: David Howells <dhowells@redhat.com>
Subject: Re: [2.6 patch] net/rxrpc/ar-connection.c: fix NULL dereference
Date: Mon, 18 Jun 2007 12:37:53 +0100
Message-ID: <22895.1182166673@redhat.com>
References: <20070615214513.GL3588@stusta.de>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51932 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751077AbXFRLjm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jun 2007 07:39:42 -0400
In-Reply-To: <20070615214513.GL3588@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk <bunk@stusta.de> wrote:

> This patch fixes a NULL dereference spotted by the Coverity checker.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Acked-by: David Howells <dhowells@redhat.com>
