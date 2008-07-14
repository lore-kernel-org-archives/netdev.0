From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: Re: [PATCH 6/6] netxen: put back driver xmit lock
Date: Mon, 14 Jul 2008 12:07:00 -0700
Message-ID: <487BA3D4.2030708@netxen.com>
References: <1215890720-29744-7-git-send-email-dhananjay@netxen.com> <20080712.135347.44219316.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1250"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"jeff@garzik.org" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.netxen.com ([66.126.254.36]:2383 "EHLO nxexch.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752178AbYGNTHD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jul 2008 15:07:03 -0400
In-Reply-To: <20080712.135347.44219316.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> This is on hold, and meanwhile there is zero reason for the
> driver to not take advantage of the mid-layer's lock.
>
> None whatsoever.
Okay, that was the last patch in the series, so can be omitted for now.
Rest may be applied.

-Dhananjay
