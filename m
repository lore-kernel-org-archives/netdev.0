From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: iproute2 : Bug found. How to report ?
Date: Mon, 24 Aug 2015 09:47:24 +0300
Message-ID: <20150824064724.GA15950@angus-think.lan>
References: <CAA5aLPh64cgnYcsz9xLQ3xkS5pcU0huxX7dt60+Fh0gQANxK2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Akshat Kakkar <akshat.1984@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:34284 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696AbbHXGuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 02:50:14 -0400
Received: by widdq5 with SMTP id dq5so39907288wid.1
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2015 23:50:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAA5aLPh64cgnYcsz9xLQ3xkS5pcU0huxX7dt60+Fh0gQANxK2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 24, 2015 at 11:40:10AM +0530, Akshat Kakkar wrote:
> Dear All,
> A behavioural bug has been found in iproute2. How and where should I report it?
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Hi,

Describe issue & send it to the netdev@vger.kernel.org and probably +CC to:
	Stephen Hemminger <stephen@networkplumber.org>

I assume this is an issue related to tc hash filters which you described
in LARTC maling list ?

Regards,
Vadim Kochan
