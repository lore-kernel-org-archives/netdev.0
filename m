From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 2/2] bridge: netlink dump interface at par with
 brctl
Date: Tue, 24 Jun 2014 10:18:06 -0400
Message-ID: <53A9889E.50101@mojatatu.com>
References: <1402151244-3324-1-git-send-email-jhs@emojatatu.com> <1402151244-3324-2-git-send-email-jhs@emojatatu.com> <5395E3C4.5080904@redhat.com> <5396EF01.7030009@mojatatu.com> <53970745.7040002@redhat.com> <539DBBB5.3000906@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfeldma@cumulusnetworks.com,
	john.r.fastabend@intel.com, roopa@cumulusnetworks.com
To: vyasevic@redhat.com, davem@davemloft.net,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:37899 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472AbaFXOSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 10:18:15 -0400
Received: by mail-ie0-f180.google.com with SMTP id rl12so302022iec.39
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 07:18:14 -0700 (PDT)
In-Reply-To: <539DBBB5.3000906@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/15/14 11:28, Jamal Hadi Salim wrote:

> Too bad i missed the net-next submission.
> I am not sure what you suggest above will improve upon readability,
> but i will take another run at it when Dave opens up.
> I know reading the patch was hard - the code was not as bad.
> We'll see.


had some cycles this morning - so i sent out a new version.
Ive tried to simplify; couldnt make it any cleverr without making
it fail for some specific use case.

cheers,
jamal
