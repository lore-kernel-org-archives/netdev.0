From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2] ipv6: fix multipath route replace error
 recovery
Date: Tue, 8 Sep 2015 11:33:47 +0200
Message-ID: <55EEAB7B.4060809@6wind.com>
References: <1441237466-22302-1-git-send-email-roopa@cumulusnetworks.com>
 <55E95285.6020102@6wind.com> <55ECA62F.9070905@cumulusnetworks.com>
 <55ED7D00.3050202@6wind.com> <55EE2541.8030707@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Mazziesaccount@gmail.com,
	hannes@stressinduktion.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	Michal Kubecek <mkubecek@suse.cz>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:36927 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753831AbbIHJeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 05:34:03 -0400
Received: by wicfx3 with SMTP id fx3so107809390wic.0
        for <netdev@vger.kernel.org>; Tue, 08 Sep 2015 02:34:01 -0700 (PDT)
In-Reply-To: <55EE2541.8030707@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/09/2015 02:01, roopa a =C3=A9crit :
> On 9/7/15, 5:03 AM, Nicolas Dichtel wrote:
[snip]
> yes, i had submitted the patch you mention above to fix a slightly di=
fferent
> problem that existed then..which
> was introduced by "51ebd3181572 ("ipv6: add support of equal cost mul=
tipath
> (ECMP)")".
> Commit "35f1b4e96b9258a3668872b1139c51e5a23eb876 ipv6: do not delete =
previously
> existing ECMP routes if add fails"
> subsequently fixed it.
Ok, got it. Thank you for the details.


Nicolas
