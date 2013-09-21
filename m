From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] declance: Remove `incompatible pointer type' warnings
Date: Sun, 22 Sep 2013 02:41:36 +0400
Message-ID: <523E20A0.6090104@cogentembedded.com>
References: <alpine.LFD.2.03.1309200008060.5967@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:45732 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823Ab3IUWle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 18:41:34 -0400
Received: by mail-la0-f50.google.com with SMTP id gx14so1479535lab.9
        for <netdev@vger.kernel.org>; Sat, 21 Sep 2013 15:41:33 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.03.1309200008060.5967@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09/20/2013 03:49 AM, Maciej W. Rozycki wrote:

> Revert damage caused by 43d620c82985b19008d87a437b4cf83f356264f7:

    Please also specify that commit's summary in parens. That's the only way 
to uniquely identify a commit and makes life a bit easier when you browse the 
commits.

> .../declance.c: In function 'cp_to_buf':
> .../declance.c:347: warning: assignment from incompatible pointer type
> .../declance.c:348: warning: assignment from incompatible pointer type
> .../declance.c: In function 'cp_from_buf':
> .../declance.c:406: warning: assignment from incompatible pointer type
> .../declance.c:407: warning: assignment from incompatible pointer type

> Also add a `const' qualifier where applicable and adjust formatting.

> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>

WBR, Sergei
