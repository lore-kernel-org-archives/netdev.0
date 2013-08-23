From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [PATCH 4/4] qlcnic: use standard NAPI weights
Date: Fri, 23 Aug 2013 15:45:17 +0200
Message-ID: <5217676D.6000608@redhat.com>
References: <1377103771-1590-1-git-send-email-mschmidt@redhat.com>,<1377103771-1590-5-git-send-email-mschmidt@redhat.com> <ADFE82A996F10145934E45547759F763311C753E@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	Dept-Eng Linux Driver <Linux-Driver@qlogic.com>
To: Himanshu Madhani <himanshu.madhani@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24659 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755387Ab3HWNpX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 09:45:23 -0400
In-Reply-To: <ADFE82A996F10145934E45547759F763311C753E@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/22/2013 08:51 AM, Himanshu Madhani wrote:
> We are in process of running performance numbers with these changes.
> I will respond once I have the performance data with the proposed
> changes.

OK. I will post a rebased patch 4/4 later if you find no performance
loss.

Thanks,
Michal
