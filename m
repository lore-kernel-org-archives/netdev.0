From: maximilian attems <janitor@sternwelten.at>
Subject: Re: [patch 8/8]  prism54/islpci_dev: replace schedule_timeout() with msleep()
Date: Thu, 2 Sep 2004 12:03:22 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040902100322.GD1876@stro.at>
References: <200409021135.57632.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, kj <kernel-janitors@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Margit Schubert-While <margitsw@t-online.de>
Content-Disposition: inline
In-Reply-To: <200409021135.57632.margitsw@t-online.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 02 Sep 2004, Margit Schubert-While wrote:

> On Thu, 02 Sep 2004, Maximilian scribeth:
> > it shouldn't hinder 2.6 in it's progression.
> I consider this a regression.
> As schedule_timeout is used elesewhere in the prism54 code,
> we are using a consistent and documented method.

you didn't answer to the unit argument in favour of msleep.

shure msleep is also consistent and documented.

--
maks
kernel janitor  	http://janitor.kernelnewbies.org/
