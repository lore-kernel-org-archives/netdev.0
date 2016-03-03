From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [iproute PATCH v2 06/20] iproute: TYPE keyword is not optional,
 fix help text accordingly
Date: Thu, 3 Mar 2016 09:21:55 -0500
Message-ID: <56D84883.3080902@mojatatu.com>
References: <20160302093800.7e7dbe71@xeon-e3>
 <1456942808-15946-1-git-send-email-phil@nwl.cc>
 <1456942808-15946-7-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>, Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33735 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932214AbcCCOV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 09:21:57 -0500
Received: by mail-io0-f194.google.com with SMTP id g203so2269199iof.0
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 06:21:56 -0800 (PST)
In-Reply-To: <1456942808-15946-7-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-03-02 01:19 PM, Phil Sutter wrote:
> +	fprintf(stderr, "          unreachable | prohibit | blackhole | nat }\n");

Dont think nat exists anymore...

cheers,
jamal
