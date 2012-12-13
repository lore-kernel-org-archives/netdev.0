From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 00/11] Add basic VLAN support to bridges
Date: Thu, 13 Dec 2012 15:17:30 -0500
Message-ID: <50CA37DA.1090905@mojatatu.com>
References: <CAJZOPZL3grqtd-Tnhr-QxkdFWrhkgcp5+fOUZSaPJd3Ker_7GQ@mail.gmail.com> <50C91506.70903@redhat.com> <20121213094719.3a7a9408@nehalam.linuxnetplumber.net> <20121213.140023.2131448980265576282.davem@davemloft.net> <20121213110404.6d662baa@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, vyasevic@redhat.com,
	or.gerlitz@gmail.com, netdev@vger.kernel.org, mst@redhat.com,
	john.r.fastabend@intel.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:47245 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753303Ab2LMURd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 15:17:33 -0500
Received: by mail-ie0-f176.google.com with SMTP id 13so4619320iea.21
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2012 12:17:33 -0800 (PST)
In-Reply-To: <20121213110404.6d662baa@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-12-13 02:04 PM, Stephen Hemminger wrote:
>
> Maybe a better filtering architecture (at the bridge level) would
> be a good project.
>

Ok, please before you go off and re-invent the winter tire - take a look 
at tc filtering which works well with any netdev and point out what the 
issues are.


cheers,
jamal
