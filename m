From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: possible BUG while using CUPS
Date: Tue, 14 Aug 2007 11:21:21 -0400
Message-ID: <46C1C871.5020803@redhat.com>
References: <46BD762F.4060801@xs4all.nl> <6bffcb0e0708130839v27b4269dqfde702c410b33fd0@mail.gmail.com> <46C07CEF.1020207@xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	linux-kernel@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: Udo van den Heuvel <udovdh@xs4all.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45391 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755568AbXHNPVa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 11:21:30 -0400
In-Reply-To: <46C07CEF.1020207@xs4all.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/13/2007 11:46 AM, Udo van den Heuvel wrote:
> Michal Piotrowski wrote:
>> On 11/08/07, Udo van den Heuvel <udovdh@xs4all.nl> wrote:
>>> Using Cups 1.2.12 on Linux 2.6.22.1.
> (...)
>>> I clikc that link and hear the ping-ping of the BUG:
>> This is very interesting. Can you reproduce this bug?
> 
> I think so. (at least: I have seen it before: clicking around in Cups
> and this crash/bug/whatever.)
> 
>>> This is on a VIA Epia EK8000. ksymoops did not really help me, this is
>>> all output I got.
>>>
>>> Ideas?
>> BTW. Please try 2.6.22.2.
> 
> Compiling...

If you can reproduce that, do it after booting with "kstack=2048" and post
that so we can see the whole stack in the oops message.
