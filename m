From: Steve Hill <steve.hill@dialogic.com>
Subject: Re: [Lksctp-developers] Fw: Intermittent SCTP multihoming breakage
Date: Thu, 8 Feb 2007 14:07:18 +0000
Message-ID: <Pine.CYG.4.58.0702081403590.460@shill1-mobl.eicon.com>
References: <E096369D937D3A4DB271B382850C5C5F48E60D@pysmail.eicon.com>
 <45CA3A63.8000306@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Steve Hill <steve.hill@dialogic.com>, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net,
	Sridhar Samudrala <sri@us.ibm.com>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eiconmtl.eicon.com ([192.219.17.124]:40896 "EHLO
	EICONMTL.eicon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161517AbXBHOGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 09:06:44 -0500
In-Reply-To: <45CA3A63.8000306@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 7 Feb 2007, Vlad Yasevich wrote:

> I think I've tracked this down.  Can you apply the attached patch on top
> of the one I posted before and re-run your test.

Using the 2.6.20 kernel on the sending side with both patches applied, the
problem seems to be fixed.

Thanks.

-- 
 - Steve Hill
   Software Engineer
   Dialogic
   Fordingbridge, Hampshire, UK
   +44-1425-651392
   steve.hill@dialogic.com
