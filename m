From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [iproute PATCH 2/4] tc: util: bore up action_a2n()
Date: Tue, 26 Jul 2016 10:24:39 -0400
Message-ID: <008e490f-d498-733b-fdd9-480d19200357@mojatatu.com>
References: <1469273290-18539-1-git-send-email-phil@nwl.cc>
 <1469273290-18539-3-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>, Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34451 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752732AbcGZOYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 10:24:46 -0400
Received: by mail-it0-f65.google.com with SMTP id u186so727859ita.1
        for <netdev@vger.kernel.org>; Tue, 26 Jul 2016 07:24:46 -0700 (PDT)
In-Reply-To: <1469273290-18539-3-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-07-23 07:28 AM, Phil Sutter wrote:
> It's a pitty this function is used nowhere, so let's polish it for use:
>
> * Loop over branch names, makes it clear that every former conditional
>   was exactly identical.
> * Support 'pipe' branch name, too.
> * Make number parsing optional.
>
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
