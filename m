From: "Diego ." <eljedi@gmail.com>
Subject: Re: Fwd: Network Core
Date: Thu, 6 Nov 2008 00:03:48 +0100
Message-ID: <530d01580811051503t74edc554g384373256f67c91@mail.gmail.com>
References: <530d01580811050939q1c1dc52fra6fc2078d86d36e@mail.gmail.com>
	 <530d01580811050940k2010ba3fpd0973f23e390c5e7@mail.gmail.com>
	 <4911FDFF.2060302@redhat.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60F08@NASANEXMB10.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Chris Snook" <csnook@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Lovich, Vitali" <vlovich@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:5944 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752204AbYKEXJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 18:09:29 -0500
Received: by yw-out-2324.google.com with SMTP id 9so143499ywe.1
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2008 15:09:28 -0800 (PST)
In-Reply-To: <FCC0EC655BD1AE408C047268D1F5DF4C3BA60F08@NASANEXMB10.na.qualcomm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

wow men!

thank all of you for the answears. Very usefull information..

thanks once again!!

On Wed, Nov 5, 2008 at 9:46 PM, Lovich, Vitali <vlovich@qualcomm.com> wrote:
>
>
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>> owner@vger.kernel.org] On Behalf Of Chris Snook
>> Sent: November-05-08 12:12 PM
>> To: Diego .
>> Cc: netdev@vger.kernel.org
>> Subject: Re: Fwd: Network Core
>>
>> Diego . wrote:
>> There are a few O'Reilly books about the kernel networking stack, and
>> anything
>> written in the past few years should be recent enough for your
>> purposes.  It
>> would probably also be helpful to read articles (such as those on
>> lwn.net) about
>> new network stack features that have been added.  The commentary there
>> will give
>> you a general idea of the challenges you'll face, but you'll need to
>> complement
>> that with experience working with the network code.
>>
>> -- Chris
> Another idea, at least perhaps from a starting point is to determine whether or not it actually needs to be in user space.  With the addition of the tx ring buffer to af_packet, it should be possible to experiment with your network stack in user space.  Once you're comfortable and feel confident with the stack itself, you can port it to kernel space eventually if you want to.
>
