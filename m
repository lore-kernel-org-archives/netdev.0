From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC net-next 1/1] : sctp: denoise deprecation log on SCTP_EVENTS
Date: Wed, 22 Jul 2015 16:36:03 +0200
Message-ID: <55AFAA53.5050003@iogearbox.net>
References: <559E4F17.9090107@mojatatu.com> <063D6719AE5E284EB5DD2968C1650D6D1CB6952D@AcuExch.aculab.com> <55AF86B2.1020001@iogearbox.net> <24639F82-1D2F-4D12-AF1C-415F87D0A182@fh-muenster.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Tuexen <tuexen@fh-muenster.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50732 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932702AbbGVOgY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 10:36:24 -0400
In-Reply-To: <24639F82-1D2F-4D12-AF1C-415F87D0A182@fh-muenster.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2015 02:30 PM, Michael Tuexen wrote:
>> On 22 Jul 2015, at 14:04, Daniel Borkmann <daniel@iogearbox.net> wrote:
...
>> Anyway, as previously stated, I doubt we'd get rid of the deprecated
>> SCTP uapi from the RFC any time soon, so, imho, we should just remove
>> these rate-limited messages altogether to stop spamming the klog ...
> ... and we will not remove it in FreeBSD either.

Right, I think same here.

> Best regards
> Michael
