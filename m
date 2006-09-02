From: Andi Kleen <ak@suse.de>
Subject: Re: Linux UDP Implementation
Date: Sat, 2 Sep 2006 13:42:21 +0200
Message-ID: <200609021342.21345.ak@suse.de>
References: <00f401c6ccc2$40ad2a90$193aa8c0@mclabhpchan5>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:64901 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1751079AbWIBLm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2006 07:42:28 -0400
To: "Gary Chan" <hpchan5@ie.cuhk.edu.hk>
In-Reply-To: <00f401c6ccc2$40ad2a90$193aa8c0@mclabhpchan5>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> It seems that the implementation (at code level) does not match with the 
> actual behaviour. I would like to seek expertise on clarifying my 
> understanding in UDP implementation so that this phenomenon can be 
> explained.

How about you just add some printks or use a tool like systemtap to instrument
the code path?  That should give some insights what is actually going on.

-Andi


-- 
VGER BF report: U 0.473534
