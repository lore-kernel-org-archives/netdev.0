From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] filter: introduce SKF_AD_VLAN_PROTO BPF extension
Date: Fri, 06 Mar 2015 18:23:44 +0100
Message-ID: <54F9E2A0.2050001@iogearbox.net>
References: <1425501718-12066-1-git-send-email-msekleta@redhat.com> <54F77336.7040006@plumgrid.com> <20150305103715.GA3432@morgoth.brq.redhat.com> <54F889EB.7000203@plumgrid.com> <54F8B680.4050307@iogearbox.net> <20150306090413.GC2841@morgoth.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>, netdev@vger.kernel.org,
	Jiri Pirko <jpirko@redhat.com>, guy@alum.mit.edu,
	atzm@stratosphere.co.jp
To: Michal Sekletar <msekleta@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42467 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738AbbCFRXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 12:23:52 -0500
In-Reply-To: <20150306090413.GC2841@morgoth.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/06/2015 10:04 AM, Michal Sekletar wrote:
...
> On recent kernels libpcap now checks only offloaded case. I have an intention to
> fix this. Do you mind being Cc'ed on PR once submitted?

Ok, sure.
