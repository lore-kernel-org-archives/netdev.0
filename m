From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH net-next 1/4] bnx2x: advertise transmit time
 stamping
Date: Sun, 22 Jul 2012 21:29:24 +0300
Message-ID: <1342981764.27035.16.camel@lb-tlvb-eilong.il.broadcom.com>
References: <cover.1342976654.git.richardcochran@gmail.com>
 <379f084af5dcbcccda309ecb0d0032196fb496f3.1342976654.git.richardcochran@gmail.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David Miller" <davem@davemloft.net>,
	"Willem de Bruijn" <willemb@google.com>,
	"Merav Sircon" <meravs@broadcom.com>
To: "Richard Cochran" <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2048 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752299Ab2GVS3l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jul 2012 14:29:41 -0400
In-Reply-To: <379f084af5dcbcccda309ecb0d0032196fb496f3.1342976654.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-07-22 at 19:15 +0200, Richard Cochran wrote:
> This driver now offers software transmit time stamping, so it should
> advertise that fact via ethtool. Compile tested only.
> 
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
> Cc: Eilon Greenstein <eilong@broadcom.com>
> Cc: Willem de Bruijn <willemb@google.com>

Thanks Richard. I was sure it was sent upstream weeks ago, but I see it
is somehow still pending to be sent. Thanks for catching it.

Acked-by: Eilon Greenstein <eilong@broadcom.com>
