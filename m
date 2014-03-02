From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: [ebtables PATCH (resent)] arptables: long option "--set-counters"
 were missing
Date: Sun, 02 Mar 2014 22:16:37 +0100
Message-ID: <53139FB5.9030004@pandora.be>
References: <20140228123113.2220.55978.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from baptiste.telenet-ops.be ([195.130.132.51]:33147 "EHLO
	baptiste.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751906AbaCBVQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2014 16:16:40 -0500
In-Reply-To: <20140228123113.2220.55978.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer schreef op 28/02/2014 13:32:
> The long option "--set-counters" where missing in option parsing.
> And the corresponding short option "-c" were not mentioned in
> the help usage text.
>
> Also update the arptables man page with a description
> of the parameter.

Applied.

Thanks,
Bart
