From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC 1/2] macvlan: Allow plugging in additional backends
Date: Mon, 14 Dec 2009 13:49:44 +0100
Message-ID: <4B263468.3060406@trash.net>
References: <1259862720-28432-1-git-send-email-arnd@arndb.de> <1259862720-28432-2-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	"" <davem@davemloft.net>, "Michael S. Tsirkin" <mst@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org,
	Patrick Mullaney <pmullaney@novell.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755784AbZLNMt4@vger.kernel.org>
In-Reply-To: <1259862720-28432-2-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann wrote:
> This patch includes only the basic framework for overriding the
> receive path. With these hooks, we can add the macvtap driver
> and potentially other drivers that directly interface with a
> hypervisor.
> 
> Loosely based on a patch by Patrick Mullaney based on another
> patch by Arnd Bergmann.

This patch looks fine to me.
