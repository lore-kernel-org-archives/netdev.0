From: "Linas Vepstas" <linasvepstas@gmail.com>
Subject: Re: [PATCH 1/5] spidernet: add missing initialization
Date: Fri, 11 Jan 2008 10:48:42 -0600
Message-ID: <3ae3aa420801110848teef1927kc8d33032f86417a7@mail.gmail.com>
References: <20080111.153859.-1300526764.kouish@swc.toshiba.co.jp>
	 <200801111344.35652.jens@de.ibm.com>
Reply-To: linasvepstas@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ishizaki Kou" <kou.ishizaki@toshiba.co.jp>,
	netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org,
	"Jeff Garzik" <jgarzik@pobox.com>
To: "Jens Osterkamp" <jens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.249]:25753 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759484AbYAKQsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 11:48:46 -0500
Received: by an-out-0708.google.com with SMTP id d31so254928and.103
        for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 08:48:42 -0800 (PST)
In-Reply-To: <200801111344.35652.jens@de.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 11/01/2008, Jens Osterkamp <jens@de.ibm.com> wrote:
> Hi Ishizaki,
>
> Linas has left the company and is no longer doing kernel related stuff,
> so I suggest, given Jeff is ok with that, that the two of us take over
> spidernet maintainership.
>
> Jens
>
> ---
>
> Change maintainership for spidernet.
>
> Signed-off-by: Jens Osterkamp <jens@de.ibm.com>

Fine with me ...

Acked-by: Linas Vepstas <linasvepstas@gmail.com>

> Index: linux-2.6/MAINTAINERS
> ===================================================================
> --- linux-2.6.orig/MAINTAINERS  2008-01-11 13:32:04.000000000 +0100
> +++ linux-2.6/MAINTAINERS       2008-01-11 13:41:32.000000000 +0100
> @@ -3613,8 +3613,10 @@
>  S:     Supported
>
>  SPIDERNET NETWORK DRIVER for CELL
> -P:     Linas Vepstas
> -M:     linas@austin.ibm.com
> +P:     Ishizaki Kou
> +M:     kou.ishizaki@toshiba.co.jp
> +P:     Jens Osterkamp
> +M:     jens@de.ibm.com
>  L:     netdev@vger.kernel.org
>  S:     Supported
>
>
