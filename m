From: jamal <hadi@cyberus.ca>
Subject: Re: wrong arp query with policy routing
Date: Fri, 21 Sep 2007 08:25:40 -0400
Message-ID: <1190377540.4261.58.camel@localhost>
References: <BAY103-DAV2BC129A14C4A29986CC0CB2B80@phx.gbl>
	 <BAY103-DAV12BF0DF9E47B1577FB9814B2B90@phx.gbl>
	 <46F29741.2030505@redhat.com>
	 <BAY103-DAV1014588479A3FF5B66EEDDB2BB0@phx.gbl>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Chuck Ebbert <cebbert@redhat.com>, netdev@vger.kernel.org
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.234]:21158 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756537AbXIUMZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 08:25:45 -0400
Received: by wr-out-0506.google.com with SMTP id 36so329380wra
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 05:25:44 -0700 (PDT)
In-Reply-To: <BAY103-DAV1014588479A3FF5B66EEDDB2BB0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Fri, 2007-21-09 at 11:08 +0200, Marco Berizzi wrote:

> thanks for the reply.
> I have tried to 'echo 1 > /proc/sys/net/ipv4/conf/eth0',
> but the 'arp whos-has' behaviour doesn't change.
> Other hints?

Give a man a fish and he'll eat for a day....

Documentation/networking/ip-sysctl.txt

cheers,
jamal



