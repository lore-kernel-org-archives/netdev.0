From: =?iso-8859-1?q?Fl=E1vio_Pires?= <flavio.defreitas@gmail.com>
Subject: Re: [Bridge] Packet per Second
Date: Fri, 14 Dec 2007 17:30:27 +0000 (UTC)
Message-ID: <nemoFri121407030300@flis.man.torun.pl>
References: <nemoFri121407105527@flis.man.torun.pl> <20071214085602.11a09070@deepthought>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bridge@osdl.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:33763 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753239AbXLNRa6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 12:30:58 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1J3EN5-0001Hk-8R
	for netdev@vger.kernel.org; Fri, 14 Dec 2007 17:30:47 +0000
Received: from gate2.ip2.com.br ([208.48.246.8])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 14 Dec 2007 17:30:47 +0000
Received: from flavio.defreitas by gate2.ip2.com.br with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 14 Dec 2007 17:30:47 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20071214085602.11a09070@deepthought> Stephen
Hemminger<shemminger@linux-foundation.org> wrote:
>  On Fri, 14 Dec 2007 15:34:10 +0000 (UTC)
>  Fl=87vio Pires <flavio.defreitas@gmail.com> wrote:
>>   Hi all,=20
>>  =20
>>   It's my first time using usenet...
>>  =20
>>   Well, I work on an ISP and we have a linux box acting as a
>> bridge+firewall. With this bridge+firewall we control the packet
>> rate per second from each client and from our repeaters. But I can`t
>> measure the packet rate per IP. Is there any tool for this?
>>  =20
>>   Actually, what I want is to measure the packet rate per IP and
>> generate graphics with mrtg or rrdtool, but for this I must have the
>> number of packets per second of each client :)
>>  =20
>>   Thank you all
>>   --
>>   Fl=87vio
>>  =20
=20

>  Not that I know of, but you might look at:
>  http://www.bandwidtharbitrator.com/

Yeah, we have a proprietary solution from etinc it does bandwidth
control and firewall... but using his firewall let this machine too
slow, so we created a box just for firewall... Then we need a way to
measure pps per host so we can determine which limits fits better to
our clients and our own needs.



--=20

I'm trying a new usenet client for Mac, Nemo OS X.
You can download it at http://www.malcom-mac.com/nemo


