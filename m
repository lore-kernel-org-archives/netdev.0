From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCHv2 08/11] fec: fix uninitialized rx buffer usage
Date: Wed, 3 Feb 2010 13:23:13 -0700
Message-ID: <fa686aa41002031223n60200eber82062031b45438b9@mail.gmail.com>
References: <cover.1265173246.git.amit.kucheria@verdurent.com>
	<ec63e5978fd5ac5d308ede5916e648ba925818eb.1265173480.git.amit.kucheria@canonical.com>
	<f10f79e7313ecdeeb59ab881795baedf2430c636.1265173480.git.amit.kucheria@canonical.com>
	<240f12ca87d7666f31263aabc620a9ec197cd8ff.1265173480.git.amit.kucheria@canonical.com>
	<cover.1265173480.git.amit.kucheria@canonical.com> <752ae69adb57d4f73fa011ba380cea1b927b9c8b.1265173480.git.amit.kucheria@canonical.com>
	<e46b06510f7eb6ca51ea8b96335b2d32ec8bf6f8.1265173480.git.amit.kucheria@canonical.com>
	<fa686aa41002030846v5044d585w7f4291f89c4b7ad@mail.gmail.com>
	<37786d4b1002031033s15d0b24et82c3f0e45112ae65@mail.gmail.com>
	<fa686aa41002031038i6b058c92g39bcf948cc9cb3ce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: List Linux Kernel <linux-kernel@vger.kernel.org>,
	Rob Herring <r.herring@freescale.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux@arm.linux.org.uk,
	s.hauer@pengutronix.de, valentin.longchamp@epfl.ch,
	daniel@caiaq.de, Dinh.Nguyen@freescale.com, bryan.wu@canonical.com
To: Amit Kucheria <amit.kucheria@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f201.google.com ([209.85.223.201]:46855 "EHLO
	mail-iw0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757886Ab0BCUXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 15:23:34 -0500
In-Reply-To: <fa686aa41002031038i6b058c92g39bcf948cc9cb3ce@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 3, 2010 at 11:38 AM, Grant Likely <grant.likely@secretlab.ca> wrote:
> On Wed, Feb 3, 2010 at 11:33 AM, Amit Kucheria
> <amit.kucheria@canonical.com> wrote:
>> On Wed, Feb 3, 2010 at 8:46 AM, Grant Likely <grant.likely@secretlab.ca> wrote:
>>>
>>> fec related patches 8 & 9 look okay to me.
>>>
>>> g.
>>
>> Can I take that as an Acked-by?
>
> of course.

BTW, since these 2 patches are essentially independent, you may find
it easier to get all the patches merged if you post the FEC changes in
a separate patch series.

g.
