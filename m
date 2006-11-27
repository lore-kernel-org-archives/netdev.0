From: David Howells <dhowells@redhat.com>
Subject: Re: [2.6 patch] kill net/rxrpc/rxrpc_syms.c
Date: Mon, 27 Nov 2006 11:21:25 +0000
Message-ID: <30354.1164626485@redhat.com>
References: <20061126040416.GH15364@stusta.de>
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758060AbWK0LZk@vger.kernel.org>
In-Reply-To: <20061126040416.GH15364@stusta.de> 
To: Adrian Bunk <bunk@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk <bunk@stusta.de> wrote:

> This patch moves the EXPORT_SYMBOL's from net/rxrpc/rxrpc_syms.c to the 
> files with the actual functions.

You can if you like.  Can you slap a blank line before each EXPORT_SYMBOL()
though please?

David
