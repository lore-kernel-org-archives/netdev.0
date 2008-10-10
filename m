From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: deadlocks if use htb
Date: Fri, 10 Oct 2008 12:52:58 +0400
Message-ID: <48EF17EA.5020306@bigtelecom.ru>
References: <20081010075640.GA5204@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:33355 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309AbYJJIxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 04:53:01 -0400
In-Reply-To: <20081010075640.GA5204@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oh... sorry. I Wrong you understand... i patch 2.6.27 with this patch
and will test it...

>> Please look to if you have time:
>> http://bugzilla.kernel.org/show_bug.cgi?id=11718
>>
>> We have deadlocks at few PC one times in week.
>> I can test any patches to detect and fix problem.
>> Now i test 2.6.27-rc kernel at one PC.
>>     
>
> A similar bug was reported by Denys Fedoryshchenko but it wasn't fully
> diagnosed. Anyway it looks like hardware dependent. The patch below
> can sometimes help. 2.6.27 may have this fixed too (some other way).
>
> Jarek P.

