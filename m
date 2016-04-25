From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [iproute2 PATCH v3 1/1] tc: introduce IFE action
Date: Mon, 25 Apr 2016 08:28:24 -0400
Message-ID: <571E0D68.1050106@mojatatu.com>
References: <1461274814-16235-1-git-send-email-jhs@emojatatu.com>
 <20160422100047.083055ee@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, phil@nwl.cc
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:35549 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932229AbcDYM2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 08:28:37 -0400
Received: by mail-io0-f169.google.com with SMTP id d62so78320634iof.2
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 05:28:36 -0700 (PDT)
In-Reply-To: <20160422100047.083055ee@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-04-22 01:00 PM, Stephen Hemminger wrote:
> On Thu, 21 Apr 2016 17:40:14 -0400

>
> All header files for iproute2 (in include/linux) should come from santized kernel
> headers. I do not see the file tc_ife.h in include/uapi/linux in current net-next
> kernel source tree.
>

I am assuming based on your other email this is taken care of?
Let me know if you want me to do something from my side.
I have other patches which build on top of this. If you have this
one i will send the others.

cheers,
jamal
