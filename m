From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] bridge: avoid br_ifinfo_notify when nothing
 changed
Date: Mon, 25 Mar 2013 20:31:40 +0400
Message-ID: <51507BEC.9000300@cogentembedded.com>
References: <514F0F07.9050702@cogentembedded.com> <20130324.171537.1255124338630598287.davem@davemloft.net> <51506DFE.4040405@cogentembedded.com> <20130325.120808.1143527366649356424.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: honkiko@gmail.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, stephen@networkplumber.org,
	herbert@gondor.hengli.com.au, zhiguo.hong@emc.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:33701 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758704Ab3CYQcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 12:32:42 -0400
Received: by mail-la0-f53.google.com with SMTP id fr10so11829671lab.12
        for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 09:32:41 -0700 (PDT)
In-Reply-To: <20130325.120808.1143527366649356424.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 25-03-2013 20:08, David Miller wrote:

>>     Sorry, I don't usuallly ACK patches in an area I'm not closely
>>     familiar with. Though I can add:

> If you feel confident enough to ask for corrections, you better be
> ready to ACK the result when your requests have been met.

   Come on, I only asked to correct an evident cut and paste typo in the 
description. That's too little a correction to ACK the whole patch. To ACK it, 
I should know well the code it's patching and be confident that the whole 
patch is correct. I have neither knowledge.

> You can't hold other people accountable yet take none of the
> same responsibility yourself.

    I don't hold anyone accountable, I just provide my comments which might as 
well be ignored by the submitter/maintainer.

WBR, Sergei
