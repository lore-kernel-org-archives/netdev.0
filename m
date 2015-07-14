From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: Fighting out-of-order reception with RPS?
Date: Tue, 14 Jul 2015 21:05:17 +0200
Message-ID: <55A55D6D.7090805@hartkopp.net>
References: <1436763470.24939.66.camel@edumazet-glaptop2.roam.corp.google.com>	<55A5424B.2000803@hartkopp.net>	<CALx6S37TMbi0s4LK_j=VyZB0-vEHBWF4nFJsNSfQOz5D-Q0ksw@mail.gmail.com> <20150714.120315.218180667705835403.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, sunil.kovvuri@gmail.com,
	jonathon.reinhart@gmail.com
To: David Miller <davem@davemloft.net>, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.216]:58762 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753132AbbGNTFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 15:05:30 -0400
In-Reply-To: <20150714.120315.218180667705835403.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 14.07.2015 21:03, David Miller wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Tue, 14 Jul 2015 11:02:16 -0700
>
>> then implement NAPI for CAN drivers as has been suggested now by
>> three very experienced developers. This solves the your OOO problem
>> and moves drivers to NAPI which is the greatly preferred interface.
>
> +1
>
> +1
>
> +1

ok got it :-)
