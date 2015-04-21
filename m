From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RFC PATCH] tc filter not show last u32 filter
Date: Tue, 21 Apr 2015 13:25:38 -0700
Message-ID: <CAHA+R7N+m0GPgvcxYXb0GbrApdTCq7RZSLj2c5Fi6b3Q8UAbTQ@mail.gmail.com>
References: <55368E7F.4030005@guap.ru>
	<55369446.10806@cogentembedded.com>
	<5536ADFC.8070601@guap.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev <netdev@vger.kernel.org>
To: "Vitaly E. Lavrov" <lve@guap.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:33866 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932714AbbDUUZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 16:25:39 -0400
Received: by wicmx19 with SMTP id mx19so71969376wic.1
        for <netdev@vger.kernel.org>; Tue, 21 Apr 2015 13:25:38 -0700 (PDT)
In-Reply-To: <5536ADFC.8070601@guap.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 21, 2015 at 1:07 PM, Vitaly E. Lavrov <lve@guap.ru> wrote:
>
> A similar patch is already exists in the
> git.kernel.org/linux-stable.git/master (commit
> b057df24a7536cce6c372efe9d0e3d1558afedf4)
> and linux-4.0.y.
>
> The patch can be applied to branches of the kernel 3.14, 3.18 and 3.19.  Why
> is this not done at once?
>

That commit should already have been backported to all stable kernels, so why
do we need a different one?
