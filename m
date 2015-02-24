From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: Re: [PATCH net-next 00/10] pktgen documentation cleanup and samples
Date: Tue, 24 Feb 2015 03:28:16 +0000
Message-ID: <1424748496.4443.14.camel@xylophone.i.decadent.org.uk>
References: <1424745019.4443.1.camel@xylophone.i.decadent.org.uk>
	 <20150223.220547.266499126808113896.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@lists.codethink.co.uk
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:56111 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812AbbBXD2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 22:28:19 -0500
In-Reply-To: <20150223.220547.266499126808113896.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-02-23 at 22:05 -0500, David Miller wrote:
> From: Ben Hutchings <ben.hutchings@codethink.co.uk>
> Date: Tue, 24 Feb 2015 02:30:19 +0000
> 
> > This series cleans up the pktgen documentation, adds and improves
> > the original sample scripts.
> 
> Series applied, but I had to fix some trailing whitespace issues
> in patch #3, and subsequently apply the rest of the changes using
> "patch -l" to make them still apply.
> 
> Please check what "git am" does with your patches unless you are
> absolutely sure, it screamed at me when I tried to apply this series.

Sorry about that.  I deliberately added the samples exactly as they had
been distributed previously, then fixed them up.  I just forgot to deal
with whitespace in those subsequent fixes.

Ben.
