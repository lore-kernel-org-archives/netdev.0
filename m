From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 0/4] irda: move it to drivers/staging so we can delete it
Date: Sun, 27 Aug 2017 08:35:43 -0700
Message-ID: <1503848143.12569.48.camel@perches.com>
References: <20170827150334.32495-1-gregkh@linuxfoundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        devel@driverdev.osuosl.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        davem@davemloft.net, samuel@sortiz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170827150334.32495-1-gregkh@linuxfoundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2017-08-27 at 17:03 +0200, Greg Kroah-Hartman wrote:
> The IRDA code has long been obsolete and broken.  So, to keep people
> from trying to use it, and to prevent people from having to maintain it,
> let's move it to drivers/staging/ so that we can delete it entirely from
> the kernel in a few releases.

MAINTAINERS should be updated as well.

It'd probably be nice to try to get an email to
the irda mailing list too if it still works.
