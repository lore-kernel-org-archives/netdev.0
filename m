From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: RE: [PATCH 4/4] qlcnic: use standard NAPI weights
Date: Fri, 30 Aug 2013 19:21:33 +0000
Message-ID: <ADFE82A996F10145934E45547759F763311D183F@avmb3.qlogic.org>
References: <1377103771-1590-1-git-send-email-mschmidt@redhat.com>,<1377103771-1590-5-git-send-email-mschmidt@redhat.com>
 <ADFE82A996F10145934E45547759F763311C753E@avmb3.qlogic.org>
 <5217676D.6000608@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Eric Dumazet" <edumazet@google.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	"Sucheta Chakraborty" <sucheta.chakraborty@qlogic.com>,
	Dept-Eng Linux Driver <Linux-Driver@qlogic.com>
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:16402 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757039Ab3H3TVi convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Aug 2013 15:21:38 -0400
In-Reply-To: <5217676D.6000608@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Michal Schmidt [mailto:mschmidt@redhat.com]
> Sent: Friday, August 23, 2013 6:45 AM
> To: Himanshu Madhani
> Cc: David Miller; netdev; Eric Dumazet; Rajesh Borundia; Shahed Shaikh;
> Jitendra Kalsaria; Sony Chacko; Sucheta Chakraborty; Dept-Eng Linux Driver
> Subject: Re: [PATCH 4/4] qlcnic: use standard NAPI weights
> 
> On 08/22/2013 08:51 AM, Himanshu Madhani wrote:
> > We are in process of running performance numbers with these changes.
> > I will respond once I have the performance data with the proposed
> > changes.
> 
> OK. I will post a rebased patch 4/4 later if you find no performance loss.
> 
> Thanks,
> Michal

The changes are okay. Please resubmit your rebased patch

Acked-by: Himanshu Madhani <himanshu.madhani@qlogic.com>

Thanks,
Himanshu
