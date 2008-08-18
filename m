From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [linux-pm] forcedeth 10de:0373 doesn't work on resume
Date: Mon, 18 Aug 2008 14:34:58 -0700
Message-ID: <86802c440808181434q2c3b20fcs197c52c51717e782@mail.gmail.com>
References: <4898AA28.8000507@simon.arlott.org.uk>
	 <20080818134814.136105c9.akpm@linux-foundation.org>
	 <200808182313.10235.rjw@sisk.pl>
	 <48A9E8B3.4040800@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	"Andrew Morton" <akpm@linux-foundation.org>, jgarzik@redhat.com,
	netdev@vger.kernel.org, linux-pm@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, ranma+kernel@tdiedrich.de
To: "Simon Arlott" <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.225]:39963 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752222AbYHRVe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 17:34:59 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2165176rvb.1
        for <netdev@vger.kernel.org>; Mon, 18 Aug 2008 14:34:58 -0700 (PDT)
In-Reply-To: <48A9E8B3.4040800@simon.arlott.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 18, 2008 at 2:25 PM, Simon Arlott <simon@fire.lp0.eu> wrote:
> On 18/08/08 22:13, Rafael J. Wysocki wrote:
>
>>> Is it still broken in current kernels?
>>
>> It probably is.
>
> If I have MSI enabled, it still doesn't work.

same problem with nv_shutdown about setting it to D3Hot?

YH
