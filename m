From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH 2/8] tc: connmark, pedit: Rename BRANCH to
 CONTROL
Date: Mon, 21 Mar 2016 12:08:23 -0700
Message-ID: <20160321120823.5ec44d28@xeon-e3>
References: <1458165384-900-1-git-send-email-phil@nwl.cc>
	<1458165384-900-3-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:12911 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756517AbcCUTnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 15:43:16 -0400
In-Reply-To: <1458165384-900-3-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Mar 2016 22:56:18 +0100
Phil Sutter <phil@nwl.cc> wrote:

> As Jamal suggested, BRANCH is the wrong name, as these keywords go
> beyond simple branch control - e.g. loops are possible, too. Therefore
> rename the non-terminal to CONTROL instead which should be more
> appropriate.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

The series no longer applies cleanly after my cleanups.
Please resubmit
