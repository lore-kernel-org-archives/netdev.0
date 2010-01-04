From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] tcp: for tcp westwood
Date: Mon, 4 Jan 2010 08:43:14 -0800
Message-ID: <20100104084314.36ce7c68@nehalam>
References: <alpine.WNT.2.00.1001041709170.3252@jhhwang>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jae-Hyun Hwang <jhhwang@os.korea.ac.kr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39149 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753397Ab0ADQnc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2010 11:43:32 -0500
In-Reply-To: <alpine.WNT.2.00.1001041709170.3252@jhhwang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 4 Jan 2010 17:18:49 +0900
Jae-Hyun Hwang <jhhwang@os.korea.ac.kr> wrote:

> From: Jae-Hyun Hwang <jhhwang@os.korea.ac.kr>
> 
> Current net/ipv4/tcp_westwood.c seems to be unnatural when compared with Westwood papers.

The code was submitted after the original Westwood paper.
There were follow up papers, and the original author promised an update but it
never appeared.
