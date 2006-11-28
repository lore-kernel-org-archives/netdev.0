From: David Howells <dhowells@redhat.com>
Subject: Re: [2.6 patch] kill net/rxrpc/rxrpc_syms.c
Date: Tue, 28 Nov 2006 11:18:54 +0000
Message-ID: <13550.1164712734@redhat.com>
References: <20061128012830.GS15364@stusta.de>  <20061126040416.GH15364@stusta.de> <30354.1164626485@redhat.com>
Cc: David Howells <dhowells@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:9699 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S935863AbWK1LT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Nov 2006 06:19:58 -0500
In-Reply-To: <20061128012830.GS15364@stusta.de> 
To: Adrian Bunk <bunk@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk <bunk@stusta.de> wrote:

> > > This patch moves the EXPORT_SYMBOL's from net/rxrpc/rxrpc_syms.c to the 
> > > files with the actual functions.
> > 
> > You can if you like.  Can you slap a blank line before each EXPORT_SYMBOL()
> > though please?
> 
> Updated patch below.

Acked-By: David Howells <dhowells@redhat.com>
