From: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] SELinux: Fix RCU deref check warning in sel_netport_insert()
Date: Tue, 04 Oct 2011 00:07:42 +0100
Message-ID: <25906.1317683262@redhat.com>
References: <2230709.7n5noARWFd@sifl> <20111003135824.15303.10147.stgit@warthog.procyon.org.uk>
Cc: dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>
Return-path: <owner-selinux-MESi4pFTnrejpDF0oNHs+n7yKkN/O5/Z@public.gmane.org>
In-Reply-To: <2230709.7n5noARWFd@sifl>
Sender: owner-selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org
List-Id: netdev.vger.kernel.org

Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org> wrote:

> We should probably do the same for the security/selinux/netif.c as it uses
> the same logic; David is this something you want to tackle?

I can have a look, but it won't be before Wednesday.

David
