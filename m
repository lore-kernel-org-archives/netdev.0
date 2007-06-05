From: Joy Latten <latten@austin.ibm.com>
Subject: Re: [PATCH]: Add security check before flushing SAD/SPD
Date: Tue, 05 Jun 2007 12:56:04 -0500
Message-ID: <1181066165.15699.37.camel@faith.austin.ibm.com>
References: <200703262321.l2QNLZlR014240@faith.austin.ibm.com>
	 <1180983953.3950.37.camel@localhost.localdomain>
	 <Line.LNX.4.64.0706041544230.13341@d.namei>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Paris <eparis@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, selinux@tycho.nsa.gov
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:51989 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006AbXFESOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 14:14:34 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l55IEXMW026037
	for <netdev@vger.kernel.org>; Tue, 5 Jun 2007 14:14:33 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l55IEUSw207884
	for <netdev@vger.kernel.org>; Tue, 5 Jun 2007 12:14:31 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l55IETlg030812
	for <netdev@vger.kernel.org>; Tue, 5 Jun 2007 12:14:30 -0600
In-Reply-To: <Line.LNX.4.64.0706041544230.13341@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-06-04 at 15:44 -0400, James Morris wrote:
> On Mon, 4 Jun 2007, Eric Paris wrote:
> 
> > Some time ago this thread bounced back and forth and seemed to come to
> > rest with the patch below, I cleaned up the comments and put all the
> > ACKs it received in one place below, but so much time has passed I doubt
> > if they should still count for free.  I also rediffed the patch against
> > the latest miller tree.  Is the idea or patch in any way flawed or
> > unacceptable to people at the moment?
> > 
> > Anyone willing to step up an re-ack the patch to get it moving into the
> > tree?
> 
> Looks good to me.
> 
> Acked-by: James Morris <jmorris@namei.org>
> 
> 

I have also tested with 2.6.22-rc3-git7 and all appears to be working as
expected. 

Acked-by: Joy Latten <latten@austin.ibm.com>


