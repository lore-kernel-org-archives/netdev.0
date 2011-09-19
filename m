From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: [BUG net-next] lost bnx2x
Date: Mon, 19 Sep 2011 14:54:10 +0300
Message-ID: <1316433250.4154.3.camel@lb-tlvb-dmitry>
References: <1316406760.2521.18.camel@edumazet-laptop>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2755 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754519Ab1ISLyY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Sep 2011 07:54:24 -0400
In-Reply-To: <1316406760.2521.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-09-18 at 21:32 -0700, Eric Dumazet wrote:
> With latest net-next, my bnx2x doesnt start
> 
> bnx2x: Can't load firmware file bnx2x/bnx2x-e1h-7.0.23.0.fw
> 
> But I do have the file in /lib/firmware/bnx2x/bnx2x-e1h-7.0.23.0.fw
> 

Just pulled net-next - bnx2x device can load and pass traffic(on x86-64)
Can you provide more details about your setup?
