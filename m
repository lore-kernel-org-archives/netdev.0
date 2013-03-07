From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] VSOCK: Split vm_sockets.h into kernel/uapi
Date: Thu, 07 Mar 2013 16:58:10 +0000
Message-ID: <26621.1362675490@warthog.procyon.org.uk>
References: <1362669973-26984-1-git-send-email-acking@vmware.com>
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	gregkh@linuxfoundation.org, davem@davemloft.net,
	pv-drivers@vmware.com
To: Andy King <acking@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362669973-26984-1-git-send-email-acking@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy King <acking@vmware.com> wrote:

> Split the vSockets header into kernel and UAPI parts.  The former gets the bits
> that used to be in __KERNEL__ guards, while the latter gets everything that is
> user-visible.  Tested by compiling vsock (+transport) and a simple user-mode
> vSockets application.
> 
> Reported-by: David Howells <dhowells@redhat.com>
> Acked-by: Dmitry Torokhov <dtor@vmware.com>
> Signed-off-by: Andy King <acking@vmware.com>

Acked-by: David Howells <dhowells@redhat.com>
