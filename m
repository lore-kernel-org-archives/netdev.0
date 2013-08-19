From: Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>
Subject: Re: [PATCH] Fix stack corruption on some architectures
Date: Mon, 19 Aug 2013 15:39:43 -0700
Message-ID: <1376951983.5082.18.camel@chimera>
References: <1376944647.5082.12.camel@chimera>
	 <52129CD4.1060200@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jan Dumon <j.dumon@option.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:43921 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330Ab3HSWjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 18:39:47 -0400
Received: by mail-pb0-f41.google.com with SMTP id rp2so5536448pbb.14
        for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 15:39:47 -0700 (PDT)
In-Reply-To: <52129CD4.1060200@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-20 at 02:31 +0400, Sergei Shtylyov wrote: 
> Hello.
> 
> On 08/20/2013 12:37 AM, Daniel Gimpelevich wrote:
> 
> > There is no need to get an interface specification if we know it's the
> > wrong one; trivial change.
> 
>     Is it related to stack corruption? If not, it's asking to be in a separate 
> patch.

Perhaps, but I'll leave that up to the maintainer(s). You should be
credited as co-author of the patch.
