From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix return value on MCAST_MSFILTER error case
Date: Wed, 21 Apr 2004 16:46:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040421164618.5ba064ea.davem@redhat.com>
References: <20040420180551.I21045@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Wright <chrisw@osdl.org>
In-Reply-To: <20040420180551.I21045@build.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 20 Apr 2004 18:05:51 -0700
Chris Wright <chrisw@osdl.org> wrote:

> Return -EINVAL if (GROUP_FILTER_SIZE(gsf->gf_numsrc) > optlen)

Good catch, applied.

Thanks Chris.
