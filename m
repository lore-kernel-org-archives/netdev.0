From: Linus Gasser <list@markas-al-nour.org>
Subject: Re: Bonding with tun-devices
Date: Fri, 23 May 2014 07:35:49 +0100
Message-ID: <537EEC45.2080101@markas-al-nour.org>
References: <537CB13A.3030100@markas-al-nour.org> <20140521155434.GC6295@redhat.com> <537D0E52.9030901@markas-al-nour.org> <20140522132436.GD6295@redhat.com> <537E0E9D.8060405@markas-al-nour.org> <20140522150025.GE6295@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from virt.linusetviviane.ch ([78.46.227.60]:49774 "EHLO
	mail.profeda.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751957AbaEWGfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 02:35:30 -0400
In-Reply-To: <20140522150025.GE6295@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 22/05/14 16:00, Veaceslav Falico a =E9crit :
> On Thu, May 22, 2014 at 03:50:05PM +0100, Linus Gasser wrote:
>> Le 22/05/14 14:24, Veaceslav Falico a =E9crit :
>>> A workaround would be to use tap devices, as they're more "real" an=
d
>>> support mac address setting.
>>
>> OK, what can I say - thank you for helping me not to have fiddled
>> around with it more than needed ;) If you manage to support
>> non-mac-connections, this would be great, of course. Else I'll have =
to
>> try Openvpn which supports tap-devices.
>
> Quick googling says that ssh -o Tunnel=3Dethernet creates a tap devic=
e, so no
> need for openvpn. Disclaimer - I've never actually tried it, so dunno=
 if
> it'll work.

I tried that, but I still only get tun-devices. Don't know why it=20
doesn't want to generate tap-devices, as both man-pages and=20
google-results say I could. Waiting for your patch then,

Linus
