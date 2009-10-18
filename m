From: Harald Welte <laforge@gnumonks.org>
Subject: Re: PF_RING: Include in main line kernel?
Date: Sun, 18 Oct 2009 14:56:17 +0200
Message-ID: <20091018125617.GI27747@prithivi.gnumonks.org>
References: <903D7FEC-34E8-4F70-ABC0-E56A3A5FBBE6@ntop.org>
 <20091014.131526.181354809.davem@davemloft.net>
 <A2EB721D-3AC9-4815-ADCC-EC0B311C5AE7@ntop.org>
 <20091014.132911.174712308.davem@davemloft.net>
 <C803B824-8249-44BA-ACCD-D9AE4AA21F92@ntop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, bcook@bpointsys.com,
	brad.doctor@gmail.com, netdev@vger.kernel.org
To: Luca Deri <deri@ntop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:53888 "EHLO
	ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754167AbZJRM4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 08:56:31 -0400
Content-Disposition: inline
In-Reply-To: <C803B824-8249-44BA-ACCD-D9AE4AA21F92@ntop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Luca,

On Wed, Oct 14, 2009 at 10:34:17PM +0200, Luca Deri wrote:

> so do you want me to start porting PF_RING facilities into
> PF_PACKET? As I have said I;m not against this: my goal is to
> include this work into the linux kernel, as it has been separate for
> too long.

I would suggest you do some analysis of each of the features that PF_RING
currently offers, and think about how each those features could be added
as an incremental change to PF_PACKET.

Then post this as a RFC to the list, see what people think about each of those
issues and follow with the actual implementation.  If you think the actual
implementation might be easier than to make a written proposal, that would
of course also be great.

Regards,
-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
