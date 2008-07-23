From: jean-pascal billaud <billaud@vmware.com>
Subject: Re: delayed ack timer, slow start and LRO
Date: Wed, 23 Jul 2008 10:38:30 -0700
Message-ID: <48876C96.1050401@vmware.com>
References: <488659A6.5030703@vmware.com> <94a7e9f304c51cd53320ad8ec923d496@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:33720 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751394AbYGWRlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 13:41:21 -0400
In-Reply-To: <94a7e9f304c51cd53320ad8ec923d496@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> On Tue, 22 Jul 2008 15:05:26 -0700, jean-pascal billaud
> <billaud@vmware.com> wrote:
>
>
>> I have a question related to the interaction between the delayed ack
>> timer, slow start and LRO.
>>
>
> AFAIK, delayed ACKs are disabled in slow start phase.
>
>
Probably a dummy question but how the receiver can know when the slow 
start phase is done, as slow start is done by the sender.

thanks for your help,

--jp


> Hagen
>
>
>
>


