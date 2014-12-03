From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip monitor: Fixed printing timestamp few times
Date: Wed, 3 Dec 2014 09:47:31 -0800
Message-ID: <20141203094731.4d310fc5@urahara>
References: <1417389262-25189-1-git-send-email-vadim4j@gmail.com>
	<20141203091338.2d32de2c@urahara>
	<20141203171126.GA7381@angus-think.wlc.globallogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vadim4j@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33256 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbaLCRrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 12:47:41 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so16217381pab.20
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 09:47:41 -0800 (PST)
In-Reply-To: <20141203171126.GA7381@angus-think.wlc.globallogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 3 Dec 2014 19:11:26 +0200
vadim4j@gmail.com wrote:

> I think it was caused by RTM_NEWNDUSEROPT which was sent by router.
> So in this case the message will be skipped with printed timestamp.

Can that be decoded? it might be useful.
