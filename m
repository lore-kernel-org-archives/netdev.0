From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 1/4] ax25 check error on memcpy_fromiovec
Date: Mon, 8 Dec 2003 21:39:03 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031208213903.0617f289.davem@redhat.com>
References: <20031208202302.C30587@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Wright <chrisw@osdl.org>
In-Reply-To: <20031208202302.C30587@build.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 8 Dec 2003 20:23:02 -0800
Chris Wright <chrisw@osdl.org> wrote:

> Check the return value on memcpy_fromiovec().

I'm fine with all of these patches, but since these problems
are not super-critical can you resend these for 2.6.1 perhaps?
