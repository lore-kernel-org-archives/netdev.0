From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] ipv4 reuses freed mem
Date: Mon, 11 Aug 2003 22:29:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030811222924.5ea129bd.davem@redhat.com>
References: <E19mFqr-00068Q-00@tetrachloride>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davej@redhat.com
In-Reply-To: <E19mFqr-00068Q-00@tetrachloride>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 11 Aug 2003 17:48:57 +0100
davej@redhat.com wrote:

> cat /proc/net/pnp will return garbage, as the fields it
> dumps are initdata.

Applied, thanks David.
