From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH-v2 1/2] mac80211: Take bitrates into account when building
 IEs.
Date: Tue, 20 Oct 2015 10:26:17 -0700
Message-ID: <56267939.50507@candelatech.com>
References: <1445361750-24707-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:58302 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754AbbJTR0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 13:26:18 -0400
Received: from [192.168.100.149] (firewall.candelatech.com [50.251.239.81])
	(using TLSv1.2 with cipher DHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	by mail2.candelatech.com (Postfix) with ESMTPSA id A15E240A9E6
	for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 10:26:17 -0700 (PDT)
In-Reply-To: <1445361750-24707-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2015 10:22 AM, greearb@candelatech.com wrote:
> From: Ben Greear <greearb@candelatech.com>
>
> If a user restricts the rateset for some reason, then the
> probe requests should not advertise rates that are not
> selected by the user.

I meant to send these to linux-wireless.

Plz ignore.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
