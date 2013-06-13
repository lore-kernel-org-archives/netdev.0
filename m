From: Nikita Kiryanov <nikita@compulab.co.il>
Subject: Re: Davicom DM9000A regression
Date: Thu, 13 Jun 2013 09:58:28 +0300
Message-ID: <51B96D94.5080002@compulab.co.il>
References: <51B87A19.4030708@compulab.co.il> <20130612212306.GA21234@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, josright123@gmail.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from softlayer.compulab.co.il ([50.23.254.55]:51232 "EHLO
	compulab.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750762Ab3FMG6c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jun 2013 02:58:32 -0400
In-Reply-To: <20130612212306.GA21234@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Francois Romie,

On 06/13/2013 12:23 AM, Francois Romieu wrote:
> Nikita Kiryanov <nikita@compulab.co.il> :
[...]
> The last version of the patch changed - not much - without notice and
> it did not contain the "tested on DM9000{A, B, E}, x86, arm" part.
>
> You may try http://marc.info/?l=linux-netdev&m=136443908225335 to
> see if it behaves the same.
>

I gave it a try and the problem persists. Not surprising since it does
have the offending phy reset.

-- 
Regards,
Nikita.
