From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] iplink: bond_slave: fix
 ad_actor/partner_oper_port_state output
Date: Tue, 9 Feb 2016 09:21:06 -0800
Message-ID: <20160209092106.394e6eff@xeon-e3>
References: <1454948038-1090-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stannous@cumulusnetworks.com,
	roopa@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35996 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754182AbcBIRUy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 12:20:54 -0500
Received: by mail-pf0-f172.google.com with SMTP id e127so35092332pfe.3
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 09:20:54 -0800 (PST)
In-Reply-To: <1454948038-1090-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  8 Feb 2016 17:13:58 +0100
Nikolay Aleksandrov <razor@blackwall.org> wrote:

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> It seems that I've made a mistake when I exported these, instead of a
> space in the end I've put a newline character which is wrong and breaks
> the single line output.
> 
> Fixes: 7d6bc3b87abad ("bonding: export 3ad actor and partner port state")
> Reported-by: Sam Tannous <stannous@cumulusnetworks.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied
