From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.25-rc: Null dereference in ip_defrag
Date: Thu, 20 Mar 2008 15:47:38 +0100
Message-ID: <47E2790A.9040206@trash.net>
References: <20080317170008.GA30338@linuxace.com> <47DEACF7.10202@openvz.org> <47DEADC4.4010609@trash.net> <20080317194014.GA7302@linuxace.com> <47DF7511.5080502@openvz.org> <47DF9099.30701@openvz.org> <20080320003917.GA9198@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: Phil Oester <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep25-int.chello.at ([62.179.121.45]:30283 "EHLO
	viefep25-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752971AbYCTOro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 10:47:44 -0400
Received: from edge02.upc.biz ([192.168.13.237]) by viefep25-int.chello.at
          (InterMail vM.7.08.02.00 201-2186-121-20061213) with ESMTP
          id <20080320144741.JEJX22837.viefep25-int.chello.at@edge02.upc.biz>
          for <netdev@vger.kernel.org>; Thu, 20 Mar 2008 15:47:41 +0100
In-Reply-To: <20080320003917.GA9198@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phil Oester wrote:
> On Tue, Mar 18, 2008 at 12:51:21PM +0300, Pavel Emelyanov wrote:
>>>> I can try either patch, but Patrick's looks simpler and thus perhaps
>>>> a better candidate this late in the -rc stage.
>>>>
>>>> Pavel - you concur?
>> Phil, I agree with Patrick's patch.
> 
> And it has survived 1.5 days without issue.  Patrick - will you be pushing
> to David?

Could you send the patch you've been using?
