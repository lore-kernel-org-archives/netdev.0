From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] make tcf_proto_lookup_ops() static
Date: Thu, 21 Oct 2004 22:57:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021225724.67cd9fba.davem@davemloft.net>
References: <20041021184426.L2357@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Wright <chrisw@osdl.org>
In-Reply-To: <20041021184426.L2357@build.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 21 Oct 2004 18:44:26 -0700
Chris Wright <chrisw@osdl.org> wrote:

> Make tcf_proto_lookup_ops() static, it's only used in cls_api.c.
> 
> Signed-off-by: Chris Wright <chrisw@osdl.org>

Applied, thanks Chris.
