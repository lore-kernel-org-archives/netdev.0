From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: Re: [PATCH 2/2] asix: fix setting custom MAC address on Asix 88178
 devices
Date: Wed, 11 Jan 2012 16:22:29 +0200
Message-ID: <20120111162229.10867aa2361hnako@www.81.fi>
References: <20120110164017.24658.9965.stgit@localhost6.localdomain6>
 <20120110164023.24658.76719.stgit@localhost6.localdomain6>
 <20120110.150051.1786115333097978498.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=ISO-8859-1;
 DelSp="Yes";
 format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, grundler@chromium.org, allan@asix.com.tw
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-mail-sa-01.sanoma.fi ([158.127.18.161]:38504 "EHLO
	sd-mail-sa-01.sanoma.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932923Ab2AKOWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2012 09:22:32 -0500
In-Reply-To: <20120110.150051.1786115333097978498.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting David Miller <davem@davemloft.net>:

>
> Please do not format your commit messages like this, everything after
> that first "---" will be stripped away.  So in this case if I applied
> this email into GIT as-is we'd lose the actual commit message and
> only have your "(Note: " thing.
>
> I fixed this up and applied it with Grant's ACK.
>

Ok, I'll avoid doing that in future. Thanks.

-Jussi
