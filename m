From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6, sit: set prefix length 64 for link-local
 addresses
Date: Fri, 26 Sep 2003 20:19:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030926201953.3dfc67bf.davem@redhat.com>
References: <20030926175405.GA31498@wsx.ksp.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jan Oravec <jan.oravec@6com.sk>
In-Reply-To: <20030926175405.GA31498@wsx.ksp.sk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 26 Sep 2003 19:54:05 +0200
Jan Oravec <jan.oravec@6com.sk> wrote:

> please apply the following patch.
> 
> It sets the prefix length 64 instead of 128 for link-local addresses on sit interfaces.

I've seen this patch before, and I remember it being rejected
by other ipv6 developers.

Do the USAGI or other folks remember what is going on here?
