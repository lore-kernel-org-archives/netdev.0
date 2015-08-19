From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next 11/13] vxlan: metadata based tunneling for
 IPv6
Date: Wed, 19 Aug 2015 12:01:30 -0700
Message-ID: <20150819190129.GB1634@Alexeis-MacBook-Pro-3.local>
References: <cover.1439978875.git.jbenc@redhat.com>
 <d07be028321109caf87da0cf00f3ae9c9ac94f63.1439978875.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33347 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877AbbHSTBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 15:01:32 -0400
Received: by padfo6 with SMTP id fo6so2891988pad.0
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 12:01:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <d07be028321109caf87da0cf00f3ae9c9ac94f63.1439978875.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 19, 2015 at 12:10:01PM +0200, Jiri Benc wrote:
> Support metadata based (formerly flow based) tunneling also for IPv6.
> This complements commit ee122c79d422 ("vxlan: Flow based tunneling").
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
>  drivers/net/vxlan.c | 69 +++++++++++++++++++++++++++++++----------------------
>  1 file changed, 40 insertions(+), 29 deletions(-)

Looks good.
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
