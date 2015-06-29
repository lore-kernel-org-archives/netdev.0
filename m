From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH RFC net-next] vxlan: GRO support at tunnel layer
Date: Mon, 29 Jun 2015 08:40:15 -0700
Message-ID: <559166DF.5070602@hp.com>
References: <1435360189-641007-1-git-send-email-tom@herbertland.com> <558DF24A.1040504@hp.com> <df94e5b8a0ed7a9146063908e3001ef3@imap.linux.ibm.com> <CALx6S35joR=WtiqXne-vkMB+R0e=4pWo2r_WiKASGQcViBsAFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>,
	Ramu Ramamurthy <sramamur@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t5008.houston.hp.com ([15.240.92.66]:54320 "EHLO
	g9t5008.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753414AbbF2PkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2015 11:40:18 -0400
In-Reply-To: <CALx6S35joR=WtiqXne-vkMB+R0e=4pWo2r_WiKASGQcViBsAFA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/28/2015 02:31 PM, Tom Herbert wrote:
> You're comparing apples to oranges. Please test the patch in your
> environment I posted and report results. Please also test with
> multiple connections, single connection performance can be misleading
> and does not really reflect what real production servers are doing.

Slight drift - Linux is, for lack of a better expression, a complete 
fruit stand.  One customer might indeed be into oranges, but I've had 
customers coming to me wanting to see shiny apples.

happy benchmarking,

rick jones
