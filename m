From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH 0/3] Fix backward compatibility of newer firmware with
 older kernel
Date: Fri, 27 Feb 2015 15:59:19 -0800
Message-ID: <CAKh23Fnyx0yFHpq=f2ko0b6X443kReGNdx1Jq=VcbQNpVnrhmA@mail.gmail.com>
References: <1425067710-14879-1-git-send-email-isubramanian@apm.com>
	<20150227.154908.1568850601715564090.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"mlangsdo@redhat.com" <mlangsdo@redhat.com>,
	patches <patches@apm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og109.obsmtp.com ([64.18.0.188]:36269 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755395AbbB0X7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 18:59:21 -0500
Received: by lbiw7 with SMTP id w7so20272715lbi.10
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 15:59:19 -0800 (PST)
In-Reply-To: <20150227.154908.1568850601715564090.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2015 at 12:49 PM, David Miller <davem@davemloft.net> wrote:
>
> This subject line is lacking, it should mention the driver (using a
> subsystem prefix following by a colon character and a space) for which
> this series's changes are being made. when someone reads:
>
>         Fix backward compatibility of newer firmware with older kernel
>
> in the git shortlog, they will have no idea where you are actually
> making these changes.

Thanks.  I will fix it.
