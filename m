From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]: Fix memory leak in ah6.c
Date: Sat, 29 May 2004 12:37:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040529123737.57b3f6ef.davem@redhat.com>
References: <40B71975.1080909@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <40B71975.1080909@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 28 May 2004 12:50:29 +0200
Patrick McHardy <kaber@trash.net> wrote:

> this patch fixes a memory leak in ah6.c. iph is not freed when
> ipv6_clear_mutable_options fails.

Applied.
