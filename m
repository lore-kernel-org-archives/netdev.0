From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [question] bridged tunnel
Date: Tue, 28 Jul 2009 10:20:29 +0200
Message-ID: <20090728082028.GB6522@psychotron.englab.brq.redhat.com>
References: <20090728075928.GB3633@psychotron.englab.brq.redhat.com> <4A6EB2EC.3050907@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Philip Craig <philipc@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34129 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750744AbZG1IU2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jul 2009 04:20:28 -0400
Content-Disposition: inline
In-Reply-To: <4A6EB2EC.3050907@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jul 28, 2009 at 10:12:28AM CEST, philipc@snapgear.com wrote:
>Jiri Pirko wrote:
>> Hello all.
>> 
>> Imagine following net scheme:
>> 
>> LAN1 --- ROUTER A --- ROUTER B --- LAN2
>> 
>> I would like to have LAN1 and LAN2 bridged together.
>
>You can do that with gretap devices.
>
>If you don't want to use GRE, then at least it provides an
>example of how to do this in the kernel.

Will look at this. Thanks
