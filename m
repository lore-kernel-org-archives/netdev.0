From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v9 00/20] simplify crypto wait for async op
Date: Tue, 17 Oct 2017 21:09:10 +0800
Message-ID: <20171017130910.GA28534@gondor.apana.org.au>
References: <1508059209-25529-1-git-send-email-gilad@benyossef.com>
 <20171015153831.GA22867@gondor.apana.org.au>
 <CAOtvUMeESbKKaEvpW_MKrRaCxwQWnBa00m4v4F1jNZ_+Xq7pWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Jonathan Corbet <corbet@lwn.net>,
        David Howells <dhowells@redhat.com>,
        Tom Lendacky <thomas.lendacky@amd.com>,
        Gary Hook <gary.hook@amd.com>,
        Boris Brezillon <boris.brezillon@free-electrons.com>,
        Arnaud Ebalard <arno@natisbad.org>,
        Matthias Brugger <matthias.bgg@gmail.com>,
        Alasdair Kergon <agk@redhat.com>,
        Mike Snitzer <snitzer@redhat.com>,
        device-mapper development <dm-devel@redhat.com>,
        Steve French <sfrench@samba.org>,
        "Theodore Y. Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>,
        Dmitry Kasatkin <dmitry.kasatkin@gmail.c
To: Gilad Ben-Yossef <gilad@benyossef.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orcrist.hmeau.com ([104.223.48.154]:38282 "EHLO
        deadmen.hmeau.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932145AbdJQNLn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 09:11:43 -0400
Content-Disposition: inline
In-Reply-To: <CAOtvUMeESbKKaEvpW_MKrRaCxwQWnBa00m4v4F1jNZ_+Xq7pWA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 17, 2017 at 02:55:21PM +0300, Gilad Ben-Yossef wrote:
>
> Would you mind if we used ENOSPC instead of E2BIG?
> 
> "No space left on device" seems more appropriate than
> "Argument list too long".

It's fine by me.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
