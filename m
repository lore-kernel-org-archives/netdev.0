From: jayant@linux.intel.com
Subject: Re: [ANN] WiMAX stack and drivers for Intel WiMAX Link 5050
Date: Tue, 8 Apr 2008 11:57:49 -0700 (PDT)
Message-ID: <4602.134.134.163.87.1207681069.squirrel@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: wimax@linuxwimax.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:39532 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753263AbYDHS5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 14:57:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>From: Stephen Hemminger [mailto:stephen.hemminger@vyatta.com]

>I notice that there is a binary supplicant required. After the
>experience with the ipw3945 driver lack of acceptance, I would
>hope that Intel would have learned that dependence on binary
>userspace components would limit acceptance especially
> with other more hostile projects (OpenBSD).

This is a temporary situation with supplicant while we resolve some
licensing issues. You should soon see us link with the opensource
supplicant. Our intention is to use all open source components whenever
available.

rgds
Jayant

