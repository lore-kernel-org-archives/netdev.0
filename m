From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC net-next 2/6] net: Preparation for vrf device
Date: Wed, 08 Jul 2015 10:40:02 +0200
Message-ID: <559CE1E2.4010708@6wind.com>
References: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com> <1436195001-4818-3-git-send-email-dsa@cumulusnetworks.com> <559CE136.7060407@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, stephen@networkplumber.org,
	hadi@mojatatu.com, ebiederm@xmission.com, davem@davemloft.net
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:38898 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933616AbbGHIkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 04:40:06 -0400
Received: by wibdq8 with SMTP id dq8so205372553wib.1
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 01:40:04 -0700 (PDT)
In-Reply-To: <559CE136.7060407@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/07/2015 10:37, Nicolas Dichtel a =C3=A9crit :
[snip]
> Also, why calling this '_MASTER', is there a notion of SLAVE?
Ok, just got it in the next patch ;-)
