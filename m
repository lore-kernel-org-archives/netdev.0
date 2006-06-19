From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Mon, 19 Jun 2006 11:34:57 -0600
Message-ID: <4496E041.5070501@nortel.com>
References: <4492D5D3.4000303@atmos.washington.edu> <44948EF6.1060201@atmos.washington.edu> <Pine.LNX.4.61.0606191638550.23553@ask.diku.dk> <200606191724.31305.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Harry Edmon <harry@atmos.washington.edu>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04e.nortel.com ([47.129.242.56]:11486 "EHLO
	zcars04e.nortel.com") by vger.kernel.org with ESMTP
	id S1751071AbWFSRfL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jun 2006 13:35:11 -0400
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200606191724.31305.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:

> Incoming packets are only time stamped
> when someone asks for the timestamps.

Doesn't that add scheduling latency to the timestamps?  Or is is a flag 
that gets set to trigger timestamping at packet arrival?

Chris
