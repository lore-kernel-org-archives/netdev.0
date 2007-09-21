From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Re: [PATCH 1/2] bnx2: factor out gzip unpacker
Date: Fri, 21 Sep 2007 18:03:55 +0100
Message-ID: <200709211803.55554.vda.linux@googlemail.com>
References: <200709211201.24475.vda.linux@googlemail.com> <20070921.091432.74736040.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, mchan@broadcom.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:39102 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753743AbXIURED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 13:04:03 -0400
Received: by nf-out-0910.google.com with SMTP id g13so843603nfb
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 10:04:01 -0700 (PDT)
In-Reply-To: <20070921.091432.74736040.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 21 September 2007 17:14, David Miller wrote:
> From: Denys Vlasenko <vda.linux@googlemail.com>
> Date: Fri, 21 Sep 2007 12:01:24 +0100
> 
> > Hi Jeff,
> 
> BNX2 and TG3 patches goes through Michael Chan and myself,
> and I usually merge them in instead of Jeff.

Didn't know that, sorry.

Do patches look ok to you?
--
vda
