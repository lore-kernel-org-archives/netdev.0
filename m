From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC net-next 0/3] Proposal for VRF-lite
Date: Tue, 09 Jun 2015 16:55:38 +0200
Message-ID: <5576FE6A.7000703@6wind.com>
References: <cover.1433561681.git.shm@cumulusnetworks.com> <5576AAD2.8010405@6wind.com> <5576F652.4090903@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: David Ahern <dsahern@gmail.com>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	hannes@stressinduktion.org, ebiederm@xmission.com,
	hadi@mojatatu.com, davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:34184 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753059AbbFIOzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 10:55:42 -0400
Received: by wgv5 with SMTP id 5so15724166wgv.1
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 07:55:40 -0700 (PDT)
In-Reply-To: <5576F652.4090903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 09/06/2015 16:21, David Ahern a =C3=A9crit :
> Hi Nicolas:
>
> On 6/9/15 2:58 AM, Nicolas Dichtel wrote:
>> I'm not really in favor of the name 'vrf'. This term is very
>> controversial and
>> having a consensus of what is/contains a 'vrf' is quite impossible.
>> There was already a lot of discussions about this topic on quagga ml
>> that show
>> that everybody has a different opinion about this term ;-)
>
> Are you referring to this thread?
> https://lists.quagga.net/pipermail/quagga-dev/2014-November/011795.ht=
ml
No, there were recent discussions on quagga about that subject. Here is=
 some
non-exhaustive pointers:
https://lists.quagga.net/pipermail/quagga-dev/2015-May/012581.html
https://lists.quagga.net/pipermail/quagga-dev/2015-May/012630.html
https://lists.quagga.net/pipermail/quagga-dev/2015-June/012715.html

Note the last pointer also explains why it was called MRF by Cumulus.


Regards,
Nicolas
