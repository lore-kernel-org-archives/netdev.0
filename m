From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 2/2] rxrpc: fix undefined behavior in rxrpc_mark_call_released
Date: Wed, 31 Aug 2016 22:05:31 +0100
Message-ID: <1505.1472677531@warthog.procyon.org.uk>
References: <6209332.zC1KBURZ66@wuerfel> <20160831123911.3467676-2-arnd@arndb.de> <20160831123911.3467676-1-arnd@arndb.de> <32632.1472675181@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, "David S. Miller" <davem@davemloft.net>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6209332.zC1KBURZ66@wuerfel>
Content-ID: <1504.1472677531.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> wrote:

> Right, sorry about that. Do you want me to resend the fixed version,
> or do you apply and fix it yourself?

I can fix it up myself.  I'll pull it into my tree when I've finished doing
the fixing up I'm currently working on.

David
