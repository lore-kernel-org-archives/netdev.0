From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Invalid timestamp? causing tight ack loop (hundreds of
 thousands of packets / sec)
Date: Thu, 05 Feb 2015 16:17:51 -0800
Message-ID: <1423181871.31870.94.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAO-X30uMA7=DTm5KqqvYC5RVTM0bg9pKBO1nX1+6x_2pF_fWfA@mail.gmail.com>
	 <1423036986.907.105.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAO-X30shOhH7tN+msRvbLreeUvZesKARqyU0Lnm3_xoeea9uaQ@mail.gmail.com>
	 <1423052431.907.112.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAO-X30umnbpQG9mwj67ZUkxQpVcGgMMsP8SqY=_3ZeoTczjbmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>
To: Avery Fay <avery@mixpanel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:38189 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751897AbbBFARy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 19:17:54 -0500
Received: by mail-ig0-f177.google.com with SMTP id z20so3307480igj.4
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 16:17:54 -0800 (PST)
In-Reply-To: <CAO-X30umnbpQG9mwj67ZUkxQpVcGgMMsP8SqY=_3ZeoTczjbmQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-02-05 at 15:25 -0800, Avery Fay wrote:

> Are these available anywhere? Or could they be made available? This
> seems like a much better solution than disabling timestamps.

Neal is currently polishing a serie of 4 patches.

This should be land to netdev shortly ;)

Thanks
