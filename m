From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: [RFC][PATCH -mm take5 7/7] update documentation
Date: Wed, 13 Jun 2007 22:47:56 +0530
Message-ID: <a781481a0706131017k368b6388n524cc2d3801be861@mail.gmail.com>
References: <466FC455.5060001@bx.jp.nec.com> <466FC79F.7090805@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Matt Mackall" <mpm@selenic.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"David Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Keiichi KII" <k-keiichi@bx.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.239]:5216 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758942AbXFMRR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 13:17:58 -0400
Received: by nz-out-0506.google.com with SMTP id n1so291979nzf
        for <netdev@vger.kernel.org>; Wed, 13 Jun 2007 10:17:57 -0700 (PDT)
In-Reply-To: <466FC79F.7090805@bx.jp.nec.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 6/13/07, Keiichi KII <k-keiichi@bx.jp.nec.com> wrote:
> From: Keiichi KII <k-keiichi@bx.jp.nec.com>
>
> update Documentation/networking/netconsole.txt
>  - how to use sysfs for dynamic configurability
>  - how to use ioctl for dynamic configurability
>
> Signed-off-by: Keiichi KII <k-keiichi@bx.jp.nec.com>

Ah, so here comes the documentation :-) Actually, I've seen a lot
of patchsets these days that prefer to submit the documentation
patch in the beginning, so that a reader / reviewer can get ready
about what to expect from the code.

Anyway, I really liked your submission. It makes netconsole
quite flexible and powerful, indeed.

Thanks,
Satyam
