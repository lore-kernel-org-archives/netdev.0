From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]: Fix NULL-ptr dereference in irlmp_get_saddr()
Date: Sat, 29 May 2004 12:40:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040529124046.5ecd1c30.davem@redhat.com>
References: <40B71AF2.2020503@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jt@bougret.hpl.hp.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <40B71AF2.2020503@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 28 May 2004 12:56:50 +0200
Patrick McHardy <kaber@trash.net> wrote:

> This patch fixes a NULL-ptr dereference in irlmp_get_saddr.

Applied.
