From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [net-next PATCH iproute2 v2 1/1] tc: introduce IFE action
Date: Thu, 21 Apr 2016 14:36:57 -0700
Message-ID: <20160421143657.51ba9fdd@xeon-e3>
References: <1457525076-6923-1-git-send-email-jhs@emojatatu.com>
	<1457525076-6923-2-git-send-email-jhs@emojatatu.com>
	<20160313232651.354f6087@xeon-e3>
	<e6070b054b0748f48991187bb4ccfccd@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"phil@nwl.cc" <phil@nwl.cc>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:3191 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751756AbcDUVgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 17:36:49 -0400
In-Reply-To: <e6070b054b0748f48991187bb4ccfccd@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Apr 2016 21:27:39 +0000
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> > The code has also gotten deeply intended creating lots of lines that are too long.
> >  
> 
> Is this you or the script saying the above? How is the conclusion that
> we have deep indentation come about?
> I checked there are some code lines that are > 80 characters because
> it doesnt make sense to break them down.

I use checkpatch from kernel source to check iproute code now.
