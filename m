From: Joy Latten <latten@austin.ibm.com>
Subject: Re: [PATCH]: xfrm audit calls
Date: Wed, 12 Sep 2007 14:35:04 -0500
Message-ID: <1189625704.15699.809.camel@faith.austin.ibm.com>
References: <200709120003.l8C03E4G004949@faith.austin.ibm.com>
	 <30135.1189623401@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com, davem@davemloft.net
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:59855 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752955AbXILTig (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 15:38:36 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8CJcXwY005465
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 15:38:33 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8CJcXUx512976
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 15:38:33 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8CJcXeT023228
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 15:38:33 -0400
In-Reply-To: <30135.1189623401@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-09-12 at 14:56 -0400, Valdis.Kletnieks@vt.edu wrote:
> On Tue, 11 Sep 2007 19:03:14 CDT, Joy Latten said:
> > This patch modifies the current ipsec audit layer
> > by breaking it up into purpose driven audit calls.
> >
> > So far, the only audit calls made are when add/delete
> > an SA/policy.
> 
> What other audit calls do you envision adding in the future?

Those specified in updated RFCs for ipsec, mainly 4301,
4302 and 4303. 

Joy
