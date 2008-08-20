From: Vince Busam <vbusam@google.com>
Subject: Re: [patch] ipvsadm: use strtoul to convert ip addresses from hex
Date: Wed, 20 Aug 2008 10:46:24 -0700
Message-ID: <48AC5870.9050000@google.com>
References: <20080820054415.GA31393@verge.net.au> <f4845fc0808200330lc1cad87ya94eb73da9b4c175@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org, wensong@linux-vs.org
To: Julius Volz <juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:11057 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751530AbYHTRq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 13:46:57 -0400
In-Reply-To: <f4845fc0808200330lc1cad87ya94eb73da9b4c175@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julius Volz wrote:
> On Wed, Aug 20, 2008 at 7:44 AM, Simon Horman <horms@verge.net.au> wrote:
>> The ip addresses that come out of /proc/net/ip_vs_conn as integers
>> are in hex not decimal.
> 
> Thanks for this fix! I'm sure Vince will release a new version with
> this once there is sunlight in his timezone :)

A new version, which also fixes a bug in sorting IPv6 addresses, is up 
at http://sixpak.org/vince/google/ipvsadm/

Vince
