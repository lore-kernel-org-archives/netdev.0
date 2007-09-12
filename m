From: Joy Latten <latten@austin.ibm.com>
Subject: Re: net-2.6.24 build problem
Date: Wed, 12 Sep 2007 10:00:57 -0500
Message-ID: <1189609257.15699.803.camel@faith.austin.ibm.com>
References: <20070912160833.73af789d@oldman>
	 <20070912.071847.10311963.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:57110 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752300AbXILPEa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 11:04:30 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8CF4TbV011320
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 11:04:29 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8CF4Sae675856
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 11:04:28 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8CF4Sdi028227
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 11:04:28 -0400
In-Reply-To: <20070912.071847.10311963.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-09-12 at 07:18 -0700, David Miller wrote:
> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Wed, 12 Sep 2007 16:08:33 +0200
> 
> > ERROR: "xfrm_audit_state_delete" [net/key/af_key.ko] undefined!
> > ERROR: "xfrm_audit_state_add" [net/key/af_key.ko] undefined!
> > ERROR: "xfrm_audit_policy_add" [net/key/af_key.ko] undefined!
> > ERROR: "xfrm_audit_policy_delete" [net/key/af_key.ko] undefined
> 
> I just checked in the following fix for this:
> 

Thanks. I took note for future reference, so it
won't happen again.

Joy


