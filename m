From: Julien Vehent <julien@linuxwall.info>
Subject: Re: TBF parameters: overhead and linklayer =?UTF-8?Q?=20=5BUTF-=38=5D=3F?=
Date: Tue, 16 Mar 2010 11:03:28 +0100
Message-ID: <4b0881d1e12a25816f9efac65c4c54ec@localhost>
References: <7370d7aa62d806f62f2a22b4095dd0ec@localhost> <cone.1268730409.349704.27722.1001@bork.lsof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Netdev <netdev@vger.kernel.org>
To: Roel van Meer <rolek@bokxing.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:38924 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937638Ab0CPKDh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 06:03:37 -0400
In-Reply-To: <cone.1268730409.349704.27722.1001@bork.lsof.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Roel,

I then found this wwebsite from your link http://www.adsl-optimizer.dk

I'm trying to find more information on how to use this... documentation is
really not easily accessible.

(currently reading latest iproute2 source code available)

On Tue, 16 Mar 2010 10:06:49 +0100, Roel van Meer <rolek@bokxing.nl>
wrote:
> Julien Vehent writes:
> 
>> TC_TBF man page seem outdated (even in latest version of iproute2) and
>> doesn't explain what those two parameters do:
>> 
>> # tc qdisc add tbf help
>> Usage: ... tbf limit BYTES burst BYTES[/BYTES] rate KBPS [ mtu
>> BYTES[/BYTES] ]
>>         [ peakrate KBPS ] [ latency TIME ] [ overhead BYTES ] [
linklayer
>> TYPE ]
>> 
>> 
>>  - overhead ?
>>  - linklayer ?
>> 
>> Or did I miss something ?
> 
> No, you're right. You might want to have a look at this page:
> http://ace-host.stuart.id.au/russell/files/tc/tc-atm/
> 
> Regards,
> 
> roel
