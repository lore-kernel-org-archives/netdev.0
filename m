From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: local route left hanging around in wrong table
Date: Wed, 9 Dec 2015 18:20:12 -0700
Message-ID: <5668D34C.6080304@cumulusnetworks.com>
References: <5668B9F7.4010400@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36065 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753794AbbLJBUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 20:20:15 -0500
Received: by pacdm15 with SMTP id dm15so38542946pac.3
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 17:20:15 -0800 (PST)
In-Reply-To: <5668B9F7.4010400@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/9/15 4:32 PM, David Ahern wrote:
> At this point I don't see a simple solution to fix this for v4.4 hence
> this email -- any thoughts?

never mind.

As soon as you send up the flares you solve problem. patch coming soon.
