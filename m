From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: RE: [PATCH net-next 1/6] qlcnic: Add ethtool statistics for board
 temperature.
Date: Wed, 31 Jul 2013 18:09:00 +0000
Message-ID: <ADFE82A996F10145934E45547759F763311B0B52@avmb3.qlogic.org>
References: <cover.1375244889.git.himanshu.madhani@qlogic.com>
	<6a88678cfe46e0e4f639e8f80834dd3e4b46fdd1.1375244889.git.himanshu.madhani@qlogic.com>
 <20130730.192723.699554467882059430.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:33803 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754304Ab3GaSJE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 14:09:04 -0400
In-Reply-To: <20130730.192723.699554467882059430.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, July 30, 2013 7:27 PM
> To: Himanshu Madhani
> Cc: netdev; Dept-NX Linux NIC Driver
> Subject: Re: [PATCH net-next 1/6] qlcnic: Add ethtool statistics for board
> temperature.
> 
> From: Himanshu Madhani <himanshu.madhani@qlogic.com>
> Date: Tue, 30 Jul 2013 21:54:19 -0400
> 
> > From: Himanshu Madhani <himanshu.madhani@qlogic.com>
> >
> > o Added ethtool statistics to display adapter board
> >   temperature.
> >
> > Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
> 
> A statistic is a count of events, this is not such a thing.
> 
> Furthermore, even if this fit the model of statistical events, there is no way
> for the user to know what units the value is in.
> 
> Sorry I'm not applying these patches.

I am dropping this patch from this series and will implement HWMON API for sensing temperature.

I am resubmitting rest of the patches in this series which are unrelated to the above patch.

Thanks, 
-Himanshu
