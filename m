From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (resend) fix sock_raw behaviour
Date: Thu, 9 Oct 2003 23:53:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031009235338.7335b635.davem@redhat.com>
References: <20031008235150.A207@jeroen.pe1rxq.ampr.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeroen Vreeken <pe1rxq@amsat.org>
In-Reply-To: <20031008235150.A207@jeroen.pe1rxq.ampr.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 8 Oct 2003 23:51:50 +0200
Jeroen Vreeken <pe1rxq@amsat.org> wrote:

> This is a resend of a patch from some weeks ago that doesn't appear to have
> made it in yet...

It doesn't apply, that's why.  You patch ax25.h twice the same
exact way which causes the patch to not apply.

While we're talking about this, who is going to maintain AX25
in 2.6.x?  I don't want to be taking bug fixes and other changes
to AX25 from random people, I'd like to have a single contact
that will review the AX25 patches from other people and then
forward them off to me.
