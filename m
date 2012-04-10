From: Michal Simek <monstr@monstr.eu>
Subject: Re: net: more accurate skb truesize - regression on Microblaze
Date: Tue, 10 Apr 2012 16:38:40 +0200
Message-ID: <4F8445F0.8070500@monstr.eu>
References: <CAHTX3dLRR09_QaA2BzmbCVAUVVGvr_P3s2d1KEgPLMYGGVzrpA@mail.gmail.com> <20120410.095245.1556231435417125908.davem@davemloft.net> <CAHTX3dLz9+A48u6ckGiDytBkyMrvgV0Zi3xfnt4RBmoagJbndA@mail.gmail.com> <20120410.101400.1433881148267812355.davem@davemloft.net>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	john.williams@petalogix.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:59266 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753470Ab2DJOir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 10:38:47 -0400
Received: by eekc41 with SMTP id c41so1353016eek.19
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 07:38:46 -0700 (PDT)
In-Reply-To: <20120410.101400.1433881148267812355.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/2012 04:14 PM, David Miller wrote:
> From: Michal Simek<monstr@monstr.eu>
> Date: Tue, 10 Apr 2012 16:04:18 +0200
>
>> I didn't report problem on any private held driver. I think you have
>> misunderstand our later discussion about ll_temac driver where are
>> some problems which at least
>
> Thanks for the clarification.

No worries.

Thanks,
Michal

-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian
