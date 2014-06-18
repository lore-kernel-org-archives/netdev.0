From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: How is IPv6 dhcp supposed to work?
Date: Wed, 18 Jun 2014 13:43:55 +0200
Message-ID: <CAPh34me+ukPUtwhANiBMJr-vmiDwy+9+kZaRgXgxi5Ba2YA99Q@mail.gmail.com>
References: <53A0B617.6070600@candelatech.com>
	<1403044471.16272.20.camel@dcbw.local>
	<53A0CC31.6090707@candelatech.com>
	<87ha3isdu6.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Greear <greearb@candelatech.com>,
	Dan Williams <dcbw@redhat.com>, netdev <netdev@vger.kernel.org>
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f176.google.com ([209.85.220.176]:61335 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933979AbaFRLn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 07:43:56 -0400
Received: by mail-vc0-f176.google.com with SMTP id ik5so639385vcb.35
        for <netdev@vger.kernel.org>; Wed, 18 Jun 2014 04:43:56 -0700 (PDT)
In-Reply-To: <87ha3isdu6.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Strange, exactly today a updated ID was released, titled:
"DHCPv6/SLAAC Address Configuration Interaction Problem Statement"
[1]. To quote the conclusion: "The host behavior of SLAAC/DHCPv6
interaction is ambiguous in standard". ;-)

Cheers, Hagen

[1] http://tools.ietf.org/html/draft-ietf-v6ops-dhcpv6-slaac-problem-01
