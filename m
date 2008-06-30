From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: Problem with sky2 (Yukon-EC)
Date: Mon, 30 Jun 2008 22:01:32 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0806302158270.4958@bizon.gios.gov.pl>
References: <Pine.LNX.4.64.0806302104141.4958@bizon.gios.gov.pl>
 <20080630125414.3876f342@extreme>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-443523211-1214856092=:4958"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:60633 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754145AbYF3UBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 16:01:36 -0400
In-Reply-To: <20080630125414.3876f342@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-443523211-1214856092=:4958
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Mon, 30 Jun 2008, Stephen Hemminger wrote:
<CUT>
> There was a fix to reset vlan offloading in 2.6.26
>
> commit d494eacde8858f9b53f5c640692caf14eb3c8239
> Author: Stephen Hemminger <shemminger@vyatta.com>
> Date:   Wed May 14 17:04:13 2008 -0700

<CUT>

Yep, I just found this patch looking for recent fixes in 2.6.26. ;)
Looks very promising. Thank you.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-443523211-1214856092=:4958--
