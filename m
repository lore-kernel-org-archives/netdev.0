From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: [PATCH] sctp compilation failed due to lack of
 sctp_local_addr_free
Date: Thu, 26 May 2011 19:41:09 +0300
Message-ID: <1306428069.7510.5.camel@lb-tlvb-dmitry>
References: <1306427323.7510.2.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "david Miller" <davem@davemloft.net>,
	"Jacek Luczak" <difrost.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3923 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757627Ab1EZQlP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 May 2011 12:41:15 -0400
In-Reply-To: <1306427323.7510.2.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-05-26 at 09:28 -0700, Dmitry Kravkov wrote:
> ---
>  net/sctp/bind_addr.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 

It was easier to fix it like commit
1231f0baa547a541a7481119323b7f964dda4788 does, than to disable it in
kernel config :)




