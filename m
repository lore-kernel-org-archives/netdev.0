From: David Howells <dhowells@redhat.com>
Subject: Re: [2.6 patch] kill net/rxrpc/rxrpc_syms.c
Date: Tue, 20 Feb 2007 10:59:46 +0000
Message-ID: <18861.1171969186@redhat.com>
References: <20070220000639.GF13958@stusta.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932868AbXBTLBy@vger.kernel.org>
In-Reply-To: <20070220000639.GF13958@stusta.de> 
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk <bunk@stusta.de> wrote:

>  } /* end rxrpc_create_call() */
> +EXPORT_SYMBOL(rxrpc_create_call);

A blank line between the end of the function and the EXPORT_SYMBOL please.

David
