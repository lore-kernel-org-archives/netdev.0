From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: Vlan interface nuisance
Date: Mon, 2 Mar 2009 14:36:05 -0500
Message-ID: <20090302193604.GI23244@csclub.uwaterloo.ca>
References: <20090301204731.40ce346a@nehalam> <20090302172057.GA23247@csclub.uwaterloo.ca> <49AC2A9C.5090303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:52484 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751895AbZCBTgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 14:36:08 -0500
Content-Disposition: inline
In-Reply-To: <49AC2A9C.5090303@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 02, 2009 at 07:51:08PM +0100, Jarek Poplawski wrote:
> Even if you have only one ethX?

Yes.  What vlan number is vlan0 talking to on ethX?

Not that eth0 ever told you much useful, but at least eth0.0005 told
you something.  I guess vconfig chose the name anyhow before, so no
reason to not continue to let user space take care of what to name it.

-- 
Len Sorensen
