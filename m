From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Subject: Re: [PATCH] INET: fix incorrect "inet_sock->is_icsk" assignment
Date: Tue, 9 Jan 2007 12:52:43 -0200
Message-ID: <39e6f6c70701090652w2c42fc9eo7768c145ac16f745@mail.gmail.com>
References: <20070108132548.GA2324@ff.dom.local>
	 <200701080947.29270.paul.moore@hp.com>
	 <20070109084322.GB1703@ff.dom.local>
	 <200701090926.47206.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@o2.pl>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.226]:25296 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932119AbXAIOwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 09:52:44 -0500
Received: by wr-out-0506.google.com with SMTP id 71so1455284wri
        for <netdev@vger.kernel.org>; Tue, 09 Jan 2007 06:52:44 -0800 (PST)
To: "Paul Moore" <paul.moore@hp.com>
In-Reply-To: <200701090926.47206.paul.moore@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/9/07, Paul Moore <paul.moore@hp.com> wrote:
> On Tuesday 09 January 2007 3:43 am, Jarek Poplawski wrote:
> > ... But if you consider this code will probably become classical
> > and will be read, quoted and teached next 1000 years, then the style
> > could matter...
>
> This from the guy who believes "Justin Timberlake rocks!" ;)
>
> All right, you convinced me, I'll send out a patch to the patch later today.

/me grins

I see I don't have to worry that much with style nitpicking, keep it up!

- Arnaldo
