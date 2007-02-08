From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [Lksctp-developers] Fw: Intermittent SCTP multihoming breakage
Date: Thu, 08 Feb 2007 09:15:48 -0500
Message-ID: <45CB3094.7080208@hp.com>
References: <E096369D937D3A4DB271B382850C5C5F48E60D@pysmail.eicon.com> <45CA3A63.8000306@hp.com> <Pine.CYG.4.58.0702081403590.460@shill1-mobl.eicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Sridhar Samudrala <sri@us.ibm.com>
To: Steve Hill <steve.hill@dialogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:43795 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423038AbXBHOPw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Feb 2007 09:15:52 -0500
In-Reply-To: <Pine.CYG.4.58.0702081403590.460@shill1-mobl.eicon.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Hill wrote:
> On Wed, 7 Feb 2007, Vlad Yasevich wrote:
> 
>> I think I've tracked this down.  Can you apply the attached patch on top
>> of the one I posted before and re-run your test.
> 
> Using the 2.6.20 kernel on the sending side with both patches applied, the
> problem seems to be fixed.
> 
> Thanks.
> 

Excellent.  I'll push out the new ones to Sridhar today.

-vlad
