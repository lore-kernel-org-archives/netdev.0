From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 0/4] irda: move it to drivers/staging so we can delete it
Date: Mon, 28 Aug 2017 16:46:07 -0700
Message-ID: <1503963967.2040.14.camel@perches.com>
References: <20170827150334.32495-1-gregkh@linuxfoundation.org>
         <20170828.164208.1908438929113102094.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org
To: David Miller <davem@davemloft.net>, gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170828.164208.1908438929113102094.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-08-28 at 16:42 -0700, David Miller wrote:
> From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Date: Sun, 27 Aug 2017 17:03:30 +0200
> 
> > The IRDA code has long been obsolete and broken.  So, to keep people
> > from trying to use it, and to prevent people from having to maintain it,
> > let's move it to drivers/staging/ so that we can delete it entirely from
> > the kernel in a few releases.
> 
> No objection, I'll apply this to net-next, thanks Greg.

Still needs an update to MAINTAINERS.
