From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: Re: [RFC][PATCH -mm take3 2/6][resend] support multiple logging
Date: Thu, 22 Mar 2007 19:03:38 +0900
Message-ID: <4602547A.5000600@bx.jp.nec.com>
References: <45FFCF31.3040000@bx.jp.nec.com> <45FFD2E5.9070208@bx.jp.nec.com> <b6fcc0a0703200534w179a664dk6bfc6108879bde94@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:39562 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030332AbXCVKD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 06:03:59 -0400
In-Reply-To: <b6fcc0a0703200534w179a664dk6bfc6108879bde94@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> On 3/20/07, Keiichi KII <k-keiichi@bx.jp.nec.com> wrote:
>> This patch contains the following changes for supporting multiple logging
>>  agents.
> 
>> +#define CONFIG_SEPARATOR ";"
> 
> CONFIG_* is reserved for configuration options. Since you use
> it in only one place just use semicolon directly.

Thank you for your reply.
I'm going to fix this when I send patches next time.


