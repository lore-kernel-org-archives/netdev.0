From: Joy Latten <latten@austin.ibm.com>
Subject: Re: [PATCH]: revised make xfrm_audit_log more generic patch
Date: Tue, 24 Jul 2007 11:33:26 -0500
Message-ID: <1185294806.15699.367.camel@faith.austin.ibm.com>
References: <200707232146.l6NLk50u001083@faith.austin.ibm.com>
	 <200707241104.56310.sgrubb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, linux-audit@redhat.com
To: Steve Grubb <sgrubb@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:34576 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751393AbXGXQfg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 12:35:36 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6OGandY007783
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 12:36:49 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6OGZVoe209960
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 12:35:33 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6OGZVs6031822
	for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 12:35:31 -0400
In-Reply-To: <200707241104.56310.sgrubb@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-07-24 at 11:04 -0400, Steve Grubb wrote:

> It also wouldn't hurt to change the text being sent to this function to have a 
> hyphen instead of a space, so "SPD delete" becomes "SPD-delete". This keeps 
> the parser happy.
> 
Steve, more for my education, should all entries have this sort of
syntax, that is, a hyphen in it? I imagine some entries might be a 
bit more wordy and so I was wondering ahead of time how to do it.

Thanks!!

Joy
