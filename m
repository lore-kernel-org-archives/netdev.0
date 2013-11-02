From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next 00/10] Mellanox driver updates Oct 31 2013
Date: Sat, 2 Nov 2013 21:14:12 +0200
Message-ID: <CAJZOPZ+kiB3JD4pGXBn0ScAATdyc9vVKz=1783YX0Cffb+3Bew@mail.gmail.com>
References: <1383222569-10930-1-git-send-email-ogerlitz@mellanox.com>
	<20131102.022003.626036008640723018.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Roland Dreier <roland@kernel.org>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:43975 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096Ab3KBTOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Nov 2013 15:14:14 -0400
Received: by mail-pd0-f179.google.com with SMTP id y10so5211557pdj.10
        for <netdev@vger.kernel.org>; Sat, 02 Nov 2013 12:14:13 -0700 (PDT)
In-Reply-To: <20131102.022003.626036008640723018.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 2, 2013 at 8:20 AM, David Miller <davem@davemloft.net> wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>

>> The series is against net-next commit ba48650 "ipv6: remove the
>> unnecessary statement in find_match()"
>> Patch #1 is bug fix which needs to go into -stable of kernels >= 3.10

> You cannot submit via net-next a bug fix that you want to go to -stable.
> I've stated this a thousand times.
> You MUST submit the bug fix for "net", not "net-next".
> I'm tossing this entire series, submit your changes correctly.

Dave, I was under the impression that since its way very late into the
3.12 cycle, the fix should land in 3.13-rc1 and fly to 3.12-stable
from there. I understand now (and sorry but this stating of your I
probably missed) that such fixes we need to submit for "net" and you
will take it from there, will do.

Or.
