From: William Dauchy <wdauchy@gmail.com>
Subject: Re: [Xen-devel] [PATCH 6/6] xen-netback: don't disconnect frontend
 when seeing oversize frame
Date: Wed, 27 Mar 2013 11:03:13 +0100
Message-ID: <CAJ75kXbRfV8pDuoptQUOZmgmMVLC0tEX3EZAWMNB1Q8gUwQw-w@mail.gmail.com>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
 <1364209702-12437-7-git-send-email-wei.liu2@citrix.com> <20130325165834.GC25740@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Wei Liu <wei.liu2@citrix.com>, netdev@vger.kernel.org,
	annie.li@oracle.com, david.vrabel@citrix.com,
	Ian Campbell <ian.campbell@citrix.com>,
	xen-devel <xen-devel@lists.xen.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f171.google.com ([209.85.220.171]:56674 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754572Ab3C0KDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 06:03:34 -0400
Received: by mail-vc0-f171.google.com with SMTP id ha11so6297414vcb.2
        for <netdev@vger.kernel.org>; Wed, 27 Mar 2013 03:03:33 -0700 (PDT)
In-Reply-To: <20130325165834.GC25740@phenom.dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 25, 2013 at 5:58 PM, Konrad Rzeszutek Wilk
<konrad.wilk@oracle.com> wrote:
> CC stable@vger.kernel.org ?

I agree on that. I got several issues with the previous patch on a 3.4.x

Regards,
--
William
