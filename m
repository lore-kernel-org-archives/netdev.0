From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 00/11] Add basic VLAN support to bridges
Date: Thu, 13 Dec 2012 17:37:03 -0500
Message-ID: <50CA588F.9040800@mojatatu.com>
References: <CAJZOPZL3grqtd-Tnhr-QxkdFWrhkgcp5+fOUZSaPJd3Ker_7GQ@mail.gmail.com> <50C91506.70903@redhat.com> <20121213094719.3a7a9408@nehalam.linuxnetplumber.net> <20121213.140023.2131448980265576282.davem@davemloft.net> <20121213110404.6d662baa@nehalam.linuxnetplumber.net> <50CA37DA.1090905@mojatatu.com> <20121213140218.2c705bb5@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, vyasevic@redhat.com,
	or.gerlitz@gmail.com, netdev@vger.kernel.org, mst@redhat.com,
	john.r.fastabend@intel.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:49100 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753028Ab2LMWhJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 17:37:09 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so2512238iay.19
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2012 14:37:06 -0800 (PST)
In-Reply-To: <20121213140218.2c705bb5@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-12-13 05:02 PM, Stephen Hemminger wrote:
> On Thu, 13 Dec 2012 15:17:30 -0500

>
> Nah, no reinvention, people who want to do filtering and bridging
> just use openvswitch instead.


so says the maintainer of bridging and iproute2.
Why cant i use bridging as is and iproute2/tc filter action?
What is the impediment for you my friend? command line cryptic,
performance problem - what is it?

cheers,
jamal
