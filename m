From: Sebastian Haas <haas@ems-wuensche.com>
Subject: Re: Staging: cpc-usb CAN driver TODO list
Date: Mon, 07 Sep 2009 10:01:42 +0200
Message-ID: <4AA4BDE6.7000707@ems-wuensche.com>
References: <4AA262CB.7060607@hartkopp.net> <4AA4A0A2.2070907@ems-wuensche.com> <4AA4B0C6.5080608@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <oliver@hartkopp.net>, Greg KH <greg@kroah.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Felipe Balbi <me@felipebalbi.com>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ems-wuensche.com ([81.169.132.244]:56754 "EHLO
	h559305.serverkompetenz.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751357AbZIGIBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 04:01:55 -0400
In-Reply-To: <4AA4B0C6.5080608@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Wolfgang,

Wolfgang Grandegger schrieb:
> Hi Sebastian,
> 
> On 09/07/2009 07:56 AM, Sebastian Haas wrote:
>> -----BEGIN PGP SIGNED MESSAGE-----
>> Hash: SHA1
>>
>> Oliver,
>>
>> I'm not yet sure how to actually start the development. There is so much
>> to do, and I've not much time to spend on this, unfortunately. Because
>> of this I can't rewrite the whole driver on my own in order to get a
>> Socket-CAN driver but I can provide support, review patches, rent
>> devices and make tests here.
>>
>> Oliver, you are not familiar with USB and I'm not very familiar with CAN
>> netdev internals, why not combining these twos. You are writing the CAN
>> part and write the USB part.
>>
>> I'll also write a specification which contains any information you need
>> to develop a CAN driver for the device (commands, sequences, error
>> handling).
> 
> Alternatively, EMS Wuensche could also hire an expert doing the job ;-).
> Note that we do a lot of Socket-CAN work in our free time, which is a
> limited resource. Progress depends on funding to a certain extend.
Money is also a limited resource. ;-)

Let's become serious again, I know and respect that many of Socket-CAN
and the Staging developers spend their free time working on it. We will
of course work on the driver, but since we've not much time it may take
several months. If someone wants to help, we would be very glad and
happy to support the person as far as we can with devices, answers and
tests.

Sebastian
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkqkveMACgkQpqRB8PJG7Xyu3ACeMhuOoVMQ043tib6HH9NhQPBw
uTQAnjCFIqzv6dQl9iRiWopVYWAirdKb
=MRvL
-----END PGP SIGNATURE-----
-- 
EMS Dr. Thomas Wuensche e.K.
Sonnenhang 3
85304 Ilmmuenster
HRA Neuburg a.d. Donau, HR-Nr. 70.106
Phone: +49-8441-490260
Fax  : +49-8441-81860
http://www.ems-wuensche.com
