From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: r8169 MAC addresses broken
Date: Mon, 03 Nov 2008 15:50:55 +0100
Message-ID: <490F0FCF.4060905@gmail.com>
References: <490380C8.6070003@simon.arlott.org.uk>	<4903947A.3060206@gmail.com>	<20081025223443.GA30913@electric-eye.fr.zoreil.com>	<4904A7C5.7090801@gmail.com>	<20081026174654.GB24790@electric-eye.fr.zoreil.com>	<4906E4BE.9050304@gmail.com> <m3mygozvd4.fsf@maximus.localdomain> <490718C7.3010501@gmail.com> <490EBE83.7030309@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Halasa <khc@pm.waw.pl>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Simon Arlott <simon@fire.lp0.eu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Arjan van de Ven <arjan@infradead.org>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.179]:40059 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756362AbYKCOvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 09:51:05 -0500
In-Reply-To: <490EBE83.7030309@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/2008 10:04 AM, Ivan Vecera wrote:
> Jiri Slaby wrote:
>> On 10/28/2008 02:45 PM, Krzysztof Halasa wrote:
>>> Jiri Slaby <jirislaby@gmail.com> writes:
>>>
>>>>> Same thing if you unplug the battery ?
>>>> Thanks, now it seems to be OK.
>>> Well, perhaps reverting that patch was a bit premature?
>> No, it helped after reverting that patch. I think we don't want defunct 2.6.28
>> with these nics.
> I cannot agree.

You want defunct r8169 in 2.6.28? Or cannot agree with what?

> IMO the problem was in the first version of the patch that didn't
> check for invalid (zeroed) MAC address. In this case is necessary to power-off (desktop
> case) or unplug the battery (notebook case).

I see no updated patch in this thread to test -- am I missing something?
