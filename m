From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: Vlan interface nuisance
Date: Mon, 2 Mar 2009 12:20:58 -0500
Message-ID: <20090302172057.GA23247@csclub.uwaterloo.ca>
References: <20090301204731.40ce346a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:49924 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752359AbZCBRVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 12:21:01 -0500
Content-Disposition: inline
In-Reply-To: <20090301204731.40ce346a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 01, 2009 at 08:47:31PM -0800, Stephen Hemminger wrote:
> Why is interface created through netlink named 'vlan0' and
> interface created through old vconfig called 'ethX.YY'.
> Seems like the interface should be consistent.

That does seem silly.

ethX.YYYY told you which physical interface and which vlan number it was.

vlan0 tells you nothing useful.

-- 
Len Sorensen
