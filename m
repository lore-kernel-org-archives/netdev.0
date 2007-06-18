From: David Howells <dhowells@redhat.com>
Subject: Re: [RFC: 2.6 patch] net/rxrpc/ar-output.c: remove dead code
Date: Mon, 18 Jun 2007 12:40:02 +0100
Message-ID: <22946.1182166802@redhat.com>
References: <20070615214520.GM3588@stusta.de>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52419 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761124AbXFRLlm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jun 2007 07:41:42 -0400
In-Reply-To: <20070615214520.GM3588@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk <bunk@stusta.de> wrote:

> This patch removes dead code spotted by the Coverity checker.

This is the wrong solution.  'copied' should be updated.

David
