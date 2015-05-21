From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v3 net-next] iplink_bond: add support for
 ad_actor and port_key options
Date: Thu, 21 May 2015 15:27:23 -0700
Message-ID: <20150521152723.51284a72@urahara>
References: <cover.1431150701.git.jtoppins@cumulusnetworks.com>
	<e389fe24551b2c94286545fd91e7018cb29f4467.1431153512.git.jtoppins@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	shm@cumulusnetworks.com, razor@blackwall.org
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:34949 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756098AbbEUW1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 18:27:20 -0400
Received: by pdea3 with SMTP id a3so1655697pde.2
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 15:27:19 -0700 (PDT)
In-Reply-To: <e389fe24551b2c94286545fd91e7018cb29f4467.1431153512.git.jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  9 May 2015 00:01:59 -0700
Jonathan Toppins <jtoppins@cumulusnetworks.com> wrote:

> This adds support for setting and displaying the following bonding
> options:
> * ad_user_port_key
> * ad_actor_sys_prio
> * ad_actor_system
> 
> Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>

Applied to net-next branch
