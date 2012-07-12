From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: Re: 3.5rc6 sctp panic
Date: Thu, 12 Jul 2012 11:12:47 +0800
Message-ID: <CAPgLHd9OESfaKP9n6=S9ziXW6Zzyo54fZ2fPXUZY88Jp_e0=hA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, vyasevich@gmail.com, sri@us.ibm.com
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:65120 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753267Ab2GLDMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 23:12:48 -0400
Received: by qcro28 with SMTP id o28so1224481qcr.19
        for <netdev@vger.kernel.org>; Wed, 11 Jul 2012 20:12:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/11/2012 08:08 AM, Dave Jones wrote:
> I just hit this while fuzz testing, and the box locked up immediately afterwards.
> The serial log was a little mangled, I did my best to clean it up..
>
>

Hi Dave,

Can you share your test program?

>
