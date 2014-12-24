From: Heiner Kallweit <hkallweit1@gmail.com>
Subject: Re: [PATCH iproute2] ip: allow ip address show to list addresses
 with certain flags not being set
Date: Wed, 24 Dec 2014 23:10:23 +0100
Message-ID: <549B39CF.8060106@gmail.com>
References: <54986E93.4030108@gmail.com> <20141224121649.3ef9d61d@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:47229 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504AbaLXWL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 17:11:57 -0500
Received: by mail-wi0-f172.google.com with SMTP id n3so14422888wiv.17
        for <netdev@vger.kernel.org>; Wed, 24 Dec 2014 14:11:56 -0800 (PST)
In-Reply-To: <20141224121649.3ef9d61d@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 24.12.2014 um 21:16 schrieb Stephen Hemminger:
> On Mon, 22 Dec 2014 20:18:43 +0100
> Heiner Kallweit <hkallweit1@gmail.com> wrote:
> 
>> Sometimes it's needed to have "ip address show" list only addresses
>> with certain flags not being set, e.g. in network scripts.
>> As an example one might want to exclude addresses in "tentative"
>> or "deprecated" state.
>>
>> Support listing addresses with flags tentative, deprecated, dadfailed
>> not being set by prefixing the respective flag with a minus.
>>
>> Signed-off-by: Heiner Kallweit <hkallweit1@gmail.com>
> 
> Applied, but please send another patch to update manual page.
> 
OK, man patch update follows ..

Heiner
