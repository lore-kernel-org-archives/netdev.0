From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: IPv6 routing type - not at par with IPv4 one?
Date: Thu, 06 Sep 2012 15:21:56 +0200
Message-ID: <5048A374.60005@6wind.com>
References: <loom.20120906T115737-277@post.gmane.org> <1346927705.2484.22.camel@edumazet-glaptop> <7F0FC925-D0A4-4E27-AE8A-F2E0A619FB36@iki.fi>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Markus Stenberg <markus.stenberg@iki.fi>,
	netdev@vger.kernel.org
To: Markus <fingon@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:41414 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752838Ab2IFNWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 09:22:00 -0400
Received: by eaac11 with SMTP id c11so539796eaa.19
        for <netdev@vger.kernel.org>; Thu, 06 Sep 2012 06:21:59 -0700 (PDT)
In-Reply-To: <7F0FC925-D0A4-4E27-AE8A-F2E0A619FB36@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/09/2012 12:54, Markus a =E9crit :
> On 6.9.2012, at 13.35, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> Well, it  seems you missed this :
>>
>> http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next.git;a=3Dc=
ommitdiff;h=3Def2c7d7b59708d54213c7556a82d14de9a7e4475
>>
>> At least the blackhole is now supported on IPv6, so you probably hav=
e to
>> add the 'throw' bit, if it makes any sense.
>
>
> Ah, cool, teaches me to refresh my git trees before posting ;-)
> Nicolas, want to update for that too or will I?
Ok, I will send another patch for this.


Thank you,
Nicolas
