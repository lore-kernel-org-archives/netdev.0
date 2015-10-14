From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v5] net: ipv6: Make address flushing on ifdown
 optional
Date: Wed, 14 Oct 2015 12:08:35 +0200
Message-ID: <561E29A3.9080101@6wind.com>
References: <1444667587-13863-1-git-send-email-dsa@cumulusnetworks.com>
 <20151013.184539.1401344867685512636.davem@davemloft.net>
 <1444815241.2154853.409816321.48710CD1@webmail.messagingengine.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hannes@redhat.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>, dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:36216 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111AbbJNKIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 06:08:38 -0400
Received: by wicgb1 with SMTP id gb1so223695973wic.1
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 03:08:37 -0700 (PDT)
In-Reply-To: <1444815241.2154853.409816321.48710CD1@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 14/10/2015 11:34, Hannes Frederic Sowa a =C3=A9crit :
[sni]
> This sysctl is on my list to be enabled soon by default by any system=
d
> based distribution. For that reason, could you maybe remove all the
I'm not sure to understand why we add a sysctl then. Or at least, why t=
he linux
default value is different from all standard distrib. I will be like
rp_filter :/
