From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Include asm/atomic.h for atomic_t
Date: Thu, 15 Jan 2004 00:15:38 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040115001538.4e0fa334.davem@redhat.com>
References: <20040115080050.GA8430@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040115080050.GA8430@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 15 Jan 2004 19:00:50 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> include/net/flow.h uses atomic_t without including asm/atomic.h which
> sometimes causes build failures.  This patch adds the inclusion.

Applied, thanks Herbert.
