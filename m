From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: Re: [PATCH net-next 0/2] qlge: feature update
Date: Fri, 23 Aug 2013 17:49:00 +0000
Message-ID: <BECD8E8A1B550B48A1BF97C13991F60E46C758AF@avmb2.qlogic.org>
References: <20130822.221246.527881072702590889.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Ron Mercer <ron.mercer@qlogic.com>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:32831 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755728Ab3HWRtE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 13:49:04 -0400
In-Reply-To: <20130822.221246.527881072702590889.davem@davemloft.net>
Content-Language: en-US
Content-ID: <AC3635DE60139A4297129899E85C6D1D@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/22/13 10:12 PM, "David Miller" <davem@davemloft.net> wrote:

>From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
>Date: Thu, 22 Aug 2013 15:54:10 -0400
>
>> This patch series enhance the handling of nested vlan tags in Rx path.
>
>Sorry no module parameters.
>You must make a generic, kernel wide, interface for controlling behavior
>such as this.
>
>Otherwise users will need to learn unique configuration mechanisms
>to control this kind of thing for every single driver and that's
>beyond terrible.
>
>I'm not applying these patches.

I will remove module parameter and will submit it again. Meantime will
look into making it generic interface to toggle the behavior.

Thanks,
    Jiten
