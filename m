From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Wed, 26 Mar 2008 21:14:18 +0100
Message-ID: <47EAAE9A.9050305@gmail.com>
References: <47EA7DE8.9070203@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matheos Worku <Matheos.Worku@Sun.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:19473 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754830AbYCZUFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 16:05:05 -0400
Received: by ug-out-1314.google.com with SMTP id z38so180153ugc.16
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2008 13:05:03 -0700 (PDT)
In-Reply-To: <47EA7DE8.9070203@sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matheos Worku wrote, On 03/26/2008 05:46 PM:
...

> outside the driver as well.  I have attached several lockup  error 
> traces and corresponding profile data. Any clues?

Are network cards' irqs balanced? If so, could you reproduce this
with affinity set?

Regards,
Jarek P.
